
protocol ProductRemoteDataSource {
    func getProductsForBrand(brandID: String, sort: ProductsSort, completion: @escaping (Result<[ProductListItem], Error>) -> Void)
    func getProducts(sort: ProductsSort, completion: @escaping (Result<[CategorizedProductListItem], Error>) -> Void)
}
