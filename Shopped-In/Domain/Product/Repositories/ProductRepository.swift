
enum ProductsResponse {
    case success([ProductListItem])
    case error(String)
}

protocol ProductRepository {
    func getProductsByBrand(brandID: String, sort: ProductsSort, completion: @escaping (ProductsResponse) -> Void)
}
