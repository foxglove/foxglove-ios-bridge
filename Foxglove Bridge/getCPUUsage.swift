import Darwin.Mach.host_info

//// https://stackoverflow.com/a/44744883
//func getCPUUsage() -> host_cpu_load_info? {
//  let  HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride
//
//  var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
//  let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)
//
//  let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
//    host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
//  }
//
//  if result != KERN_SUCCESS{
//    print("Error  - \(#file): \(#function) - kern_result_t = \(result)")
//    return nil
//  }
//  let data = hostInfo.move()
//  hostInfo.deallocate()
//  return data
//}

// From https://github.com/dani-gavrilov/GDPerformanceView-Swift/blob/171a656040135d667f4228c3ec82f2384770d87d/GDPerformanceView-Swift/GDPerformanceMonitoring/PerformanceСalculator.swift#L94
func getCPUUsage() -> Double {
  var totalUsageOfCPU: Double = 0.0
  var threadsList: thread_act_array_t?
  var threadsCount = mach_msg_type_number_t(0)
  let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
    return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
      task_threads(mach_task_self_, $0, &threadsCount)
    }
  }

  if threadsResult == KERN_SUCCESS, let threadsList = threadsList {
    for index in 0..<threadsCount {
      var threadInfo = thread_basic_info()
      var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
      let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
          thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
        }
      }

      guard infoResult == KERN_SUCCESS else {
        break
      }

      let threadBasicInfo = threadInfo as thread_basic_info
      if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
        totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)))
      }
    }
  }

  vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
  return totalUsageOfCPU
}
