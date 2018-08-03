/// Base error protocol for Service Layer
enum ServiceError: Error {
    case runtimeError(String)
}
