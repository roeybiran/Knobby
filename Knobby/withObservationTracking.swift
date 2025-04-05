import Observation
import Foundation

// https://www.polpiella.dev/observable-outside-of-a-view
public func withObservationTracking<T: Sendable>(of value: @Sendable @escaping @autoclosure () -> T, execute: @Sendable @escaping (T) -> Void) {
  Observation.withObservationTracking {
    execute(value())
  } onChange: {
    RunLoop.current.perform {
      withObservationTracking(of: value(), execute: execute)
    }
  }
}
