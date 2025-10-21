import Foundation
import HealthKit


enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case permissionDenied
    case saveFailed
    case readFailed

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device."
        case .permissionDenied:
            return "HealthKit permission denied. Please enable in Settings."
        case .saveFailed:
            return "Failed to save data to HealthKit."
        case .readFailed:
            return "Failed to read data from HealthKit."
        }
    }
}



@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    @Published private(set) var isAuthorized = false
    @Published private(set) var isAvailable = false

    private init() {
        isAvailable = HKHealthStore.isHealthDataAvailable()
    }





    func requestAuthorization() async throws -> Bool {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            throw HealthKitError.notAvailable
        }

        let typesToShare: Set<HKSampleType> = [waterType]
        let typesToRead: Set<HKObjectType> = [waterType]

        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)

            // Check if we actually got permission
            let status = healthStore.authorizationStatus(for: waterType)
            isAuthorized = status == .sharingAuthorized

            return isAuthorized
        } catch {
            throw HealthKitError.permissionDenied
        }
    }


    func checkAuthorizationStatus() async {
        guard isAvailable,
              let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            isAuthorized = false
            return
        }

        let status = healthStore.authorizationStatus(for: waterType)
        isAuthorized = status == .sharingAuthorized
    }

    
    func saveWaterIntake(amount: Double, date: Date = Date()) async throws {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        guard isAuthorized else {
            throw HealthKitError.permissionDenied
        }

        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            throw HealthKitError.notAvailable
        }

        // Convert milliliters to liters (HealthKit uses liters)
        let liters = amount / 1000.0
        let quantity = HKQuantity(unit: .liter(), doubleValue: liters)

        let sample = HKQuantitySample(
            type: waterType,
            quantity: quantity,
            start: date,
            end: date
        )

        do {
            try await healthStore.save(sample)
        } catch {
            throw HealthKitError.saveFailed
        }
    }

    
    func readWaterIntake(for date: Date) async throws -> Double {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        guard isAuthorized else {
            throw HealthKitError.permissionDenied
        }

        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            throw HealthKitError.notAvailable
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: waterType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.readFailed)
                    return
                }

                guard let result = result,
                      let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0.0)
                    return
                }

                // Convert liters to milliliters
                let liters = sum.doubleValue(for: .liter())
                let milliliters = liters * 1000.0
                continuation.resume(returning: milliliters)
            }

            healthStore.execute(query)
        }
    }

    
    func readWaterIntake(from startDate: Date, to endDate: Date) async throws -> [Date: Double] {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        guard isAuthorized else {
            throw HealthKitError.permissionDenied
        }

        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            throw HealthKitError.notAvailable
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        var anchor = HKQueryAnchor(fromValue: 0)
        let anchorPredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: waterType,
                quantitySamplePredicate: anchorPredicate,
                options: .cumulativeSum,
                anchorDate: startDate,
                intervalComponents: DateComponents(day: 1)
            )

            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.readFailed)
                    return
                }

                guard let results = results else {
                    continuation.resume(returning: [:])
                    return
                }

                var intakeByDate: [Date: Double] = [:]

                results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        let liters = sum.doubleValue(for: .liter())
                        let milliliters = liters * 1000.0
                        intakeByDate[statistics.startDate] = milliliters
                    }
                }

                continuation.resume(returning: intakeByDate)
            }

            healthStore.execute(query)
        }
    }

    

    
    
    func deleteWaterIntake(for date: Date) async throws {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        guard isAuthorized else {
            throw HealthKitError.permissionDenied
        }

        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            throw HealthKitError.notAvailable
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: date,
            end: date,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: waterType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { [weak self] _, samples, error in
                guard let self = self else { return }

                if let error = error {
                    continuation.resume(throwing: HealthKitError.readFailed)
                    return
                }

                guard let samples = samples, !samples.isEmpty else {
                    continuation.resume()
                    return
                }

                Task {
                    do {
                        try await self.healthStore.delete(samples)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: HealthKitError.saveFailed)
                    }
                }
            }

            healthStore.execute(query)
        }
    }

    
    func syncEntries(_ entries: [WaterEntry]) async throws {
        for entry in entries {
            try await saveWaterIntake(amount: entry.amount, date: entry.timestamp)
        }
    }
}
