
enum BrandsResponse {
    case success([Brand])
    case error(String)
}

protocol BrandRepository {
    func getAllBrands(sort: BrandsSort, forceNetwork: Bool, completion: @escaping (BrandsResponse) -> Void)
}
