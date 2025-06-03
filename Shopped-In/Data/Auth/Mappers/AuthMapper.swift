class AuthMapper {
    static func toDTO(from user:User)-> UserDTO {
        return UserDTO(email: user.email, firstName: user.firstName, lastName: user.lastName, phone: user.phone)
    }
    
}
