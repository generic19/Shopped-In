
enum BrandsResponse {
    case success([Brand])
    case error(String)
}

protocol BrandRepository {
    func getAllBrands(completion: @escaping (BrandsResponse) -> Void)
}
