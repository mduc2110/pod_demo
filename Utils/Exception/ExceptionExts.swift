import Foundation

extension Error {
    public func getExceptionMessage() -> String {
        #if DEBUG
            switch self {
            case is Exception:
                return "POD Exception Error: " + (self as! Exception).message
            case is NilException:
                return "POD Nil Error: " + (self as! NilException).message
            case is AppServiceException:
                return "POD Service Error:" + (self as! AppServiceException).message
            case is AppUnauthenticatedException:
                return "POD Unauthenticated Error: " + (self as! AppUnauthenticatedException).message
            case is AppIllegalException:
                return "POD Illegal Error: " + (self as! AppIllegalException).message
            default:
                return localizedDescription
            }
        #else
            if let error = self as? AppServiceException {
                return error.message
            } else {
                return "An error has occurred"
            }
        #endif
    }
}
