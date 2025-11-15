public final class CriteriaCollector {
    private var initial: Bool

    private init(initial: Bool) {
        self.initial = initial
    }

    public static func byAnd() -> CriteriaCollector {
        return CriteriaCollector(initial: true)
    }

    public static func byOr() -> CriteriaCollector {
        return CriteriaCollector(initial: false)
    }

    @discardableResult
    public func and(_ criteria: Bool) -> CriteriaCollector {
        initial = initial && criteria
        return self
    }

    @discardableResult
    public func or(_ criteria: Bool) -> CriteriaCollector {
        initial = initial || criteria
        return self
    }

    public func getCondition() -> Bool {
        return initial
    }
}
