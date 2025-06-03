import Buy
extension AddressDTO {
    func toDomain() -> Address {
        return Address(id: self.id.rawValue,name: self.firstName ?? "", address1: self.address1 ?? "", address2: self.address2, city: self.city ?? "", country: self.country ?? "", phone: self.phone ?? "", latitude: self.latitude, longitude: self.longitude)
    }
}

extension Storefront.MailingAddressInput {
    static func from(address: Address) -> Storefront.MailingAddressInput {
        return Storefront.MailingAddressInput.create(
            address1: .value(address.address1),
            address2: .init(orNull: address.address2),
            city: .value(address.city),
            country: .value(address.country),
            firstName: .value(address.name),
            phone: .value(address.phone)
        )
    }
}
