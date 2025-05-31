
protocol BrandRemoteDataSource {
    func getAllBrands(completion: @escaping (Result<[BrandDTO], Error>) -> Void)
}
