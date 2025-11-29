//
//  HealthManager.swift
//  HealthTest
//
//  Created by 강효민 on 11/29/25.
//


import HealthKit
import Combine

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var stepCount: Int = 0
    
    init() {
        requestAuthorization()
    }
    
    
    func requestAuthorization() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let typesToRead: Set = [stepType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                self.fetchTodayStepCount()
            }
        }
    }
    
    
    func fetchTodayStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            
            DispatchQueue.main.async {
               
                self.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
}
