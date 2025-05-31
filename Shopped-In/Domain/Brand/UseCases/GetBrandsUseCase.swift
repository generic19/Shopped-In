
final class GetBrandsUseCase {
    let repository: BrandRepository
    
    init(repository: BrandRepository) {
        self.repository = repository
    }
    
    func execute(completion: @escaping (BrandsResponse) -> Void) {
        repository.getAllBrands(completion: completion)
    }
}
