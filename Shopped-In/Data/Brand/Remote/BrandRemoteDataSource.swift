
protocol BrandRemoteDataSource {
    func getAllBrands(sort: BrandsSort, forceNetwork: Bool, completion: @escaping (Result<[BrandDTO], Error>) -> Void)
}
