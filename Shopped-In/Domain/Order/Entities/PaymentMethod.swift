//
//  PaymentMethod.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 13/06/2025.
//

enum PaymentMethod: CaseIterable {
    case cashOnDelivery
    case applePay
}

extension PaymentMethod {
    var title: String {
        return switch self {
            case .applePay: "Apple Pay"
            case .cashOnDelivery: "Cash on Delivery"
        }
    }
}
