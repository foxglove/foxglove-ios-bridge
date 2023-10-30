import Darwin.Mach.task_info
import Foundation

// swiftlint:disable:next line_length
// https://github.com/dani-gavrilov/GDPerformanceView-Swift/blob/171a656040135d667f4228c3ec82f2384770d87d/GDPerformanceView-Swift/GDPerformanceMonitoring/PerformanceСalculator.swift#L129
func getMemoryUsage() -> (used: UInt64, total: UInt64) {
  var taskInfo = task_vm_info_data_t()
  var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
  let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
      task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
    }
  }

  var used: UInt64 = 0
  if result == KERN_SUCCESS {
    used = UInt64(taskInfo.phys_footprint)
  }

  let total = ProcessInfo.processInfo.physicalMemory
  return (used, total)
}
