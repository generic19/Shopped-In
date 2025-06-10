
final class GetBrandsUseCase {
    private let repository: BrandRepository
    
    init(repository: BrandRepository) {
        self.repository = repository
    }
    
    func execute(sort: BrandsSort = .title, forceNetwork: Bool = false, completion: @escaping (BrandsResponse) -> Void) {
        repository.getAllBrands(sort: sort, forceNetwork: forceNetwork, completion: completion)
    }
}
