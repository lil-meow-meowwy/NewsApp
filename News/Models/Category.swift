enum Category: String, CaseIterable, Identifiable {
    case business
    case entertainment
    case general
    case health
    case science
    case sports
    case technology
    
    var id: String { self.rawValue }
    var displayName: String { rawValue.capitalized }
}
