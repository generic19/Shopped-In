
protocol ProductRemoteDataSource {
    func getProductsForBrand(brandID: String, completion: @escaping (Result<[ProductListItem], Error>) -> Void)
}
