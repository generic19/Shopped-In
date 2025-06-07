
enum ProductsResponse {
    case success([ProductListItem])
    case error(String)
}

protocol ProductRepository {
    func getProductsByBrand(brandID: String, completion: @escaping (ProductsResponse) -> Void)
    func fetchProduct(by id: String, completion: @escaping (Product?) -> Void)

}

