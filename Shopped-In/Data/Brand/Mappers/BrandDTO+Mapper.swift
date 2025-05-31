
extension BrandDTO {
    func toDomain() -> Brand {
        return Brand(id: self.id.rawValue, title: self.title, image: self.image?.url)
    }
}
