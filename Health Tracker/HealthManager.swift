import Foundation
import HealthKit
import SwiftUI
import Combine
import WidgetKit

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()               // main access point for the HealthKit data
    
    // shared with Home/dashboard - the data
    @Published var todaySteps: Double = 0
    @Published var todayExerciseMinutes: Double = 0
    @Published var latestHeartRate: Double = 0
    @Published var todaySleepFormatted: String = "0h 0m"
    
    // asking for permissions at the start to read certain or all health data included - full user control
    func requestAuthorization() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        
        let readTypes: Set<HKObjectType> = [stepType, exerciseType, heartRateType, sleepType]
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if success {
                self.fetchAllData()
            }
        }
    }
    
    func fetchAllData() {
        fetchTodaySteps()
        fetchTodayExercise()
        fetchLatestHeartRate()
        fetchTodaySleep()
    }
    
    // calculate total steps from present day from the start
    func fetchTodaySteps() {
            guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if error != nil { return }
                guard let result = result, let sum = result.sumQuantity() else {
                    DispatchQueue.main.async {
                        self.todaySteps = 0
                        UserDefaults(suiteName: "group.com.philreddy.foodwatertracker")?.set(0, forKey: "saved_steps_count")
                    }
                    return
                }
                
                let steps = sum.doubleValue(for: HKUnit.count())
                DispatchQueue.main.async {
                    self.todaySteps = steps
                    // Save steps to memory for the notifications
                    UserDefaults(suiteName: "group.com.philreddy.foodwatertracker")?.set(steps, forKey: "saved_steps_count")
                }
            }
            healthStore.execute(query)
        }
    
    // same but for exercise minutes
    func fetchTodayExercise() {
        guard let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else { return }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if error != nil { return }
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async { self.todayExerciseMinutes = 0 }
                return
            }
            DispatchQueue.main.async {
                self.todayExerciseMinutes = sum.doubleValue(for: HKUnit.minute())
            }
        }
        healthStore.execute(query)
    }
    
    // heart rate - but the most recent updated one as it can fluctuate
    func fetchLatestHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            if error != nil { return }
            guard let sample = results?.first as? HKQuantitySample else {
                DispatchQueue.main.async { self.latestHeartRate = 0 }
                return
            }
            DispatchQueue.main.async {
                self.latestHeartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
        }
        healthStore.execute(query)
    }
    
    // total amount of hours and mins slept
    func fetchTodaySleep() {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: Date(), options: .strictEndDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            if error != nil { return }
            guard let samples = results as? [HKCategorySample] else {
                DispatchQueue.main.async { self.todaySleepFormatted = "0h 0m" }
                return
            }
            
            var totalSleepSeconds: TimeInterval = 0
            
            for sample in samples {
                // Now specifically pulling "Time In Bed" instead of Asleep stages
                if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                    totalSleepSeconds += sample.endDate.timeIntervalSince(sample.startDate)
                }
            }
            
            // converting the seconds into hrs and mins
            let hours = Int(totalSleepSeconds) / 3600
            let minutes = (Int(totalSleepSeconds) % 3600) / 60
            
            DispatchQueue.main.async {
                if hours == 0 && minutes == 0 {
                    self.todaySleepFormatted = "No Data"
                } else {
                    self.todaySleepFormatted = "\(hours)h \(minutes)m"
                }
            }
        }
        healthStore.execute(query)
    }
}
