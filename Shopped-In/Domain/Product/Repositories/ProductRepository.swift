
enum ProductsResponse {
    case success([ProductListItem])
    case error(String)
}


enum CategorizedProductsResponse {
    case success([CategorizedProductListItem])
    case error(String)
}

protocol ProductRepository {
    func getProductsByBrand(brandID: String, sort: ProductsSort, completion: @escaping (CategorizedProductsResponse) -> Void)
    func getProducts(sort: ProductsSort, completion: @escaping (CategorizedProductsResponse) -> Void)
    func fetchProduct(by id: String, completion: @escaping (Product?) -> Void)
}

