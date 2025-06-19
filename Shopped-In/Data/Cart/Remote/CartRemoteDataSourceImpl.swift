//
//  CartRemoteDataSourceImpl.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 11/06/2025.
//

import Buy

class CartRemoteDataSourceImpl: CartRemoteDataSource {
    private let service: APIService

    init(service: APIService) {
        self.service = service
    }

    func createCart(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        let lineItem = Storefront.CartLineInput.create(
            merchandiseId: .init(rawValue: variantId),
            quantity: .value(Int32(quantity))
        )

        let mutation = Storefront.buildMutation {
            $0.cartCreate(input: Storefront.CartInput.create(lines: .value([lineItem]))) {
                $0.cart {
                    $0.id()
                }
                $0.userErrors {
                    $0.message()
                }
            }
        }

        service.client.mutateGraphWith(mutation) { response, error in
            if let errors = response?.cartCreate?.userErrors, !errors.isEmpty {
                let errorMessages = errors.compactMap { $0.message }.joined(separator: ", ")
                completion(.errorMessage(errorMessages))
            } else if let error = error {
                completion(.failure(error))
            } else if let cartId = response?.cartCreate?.cart?.id {
                CartSessionRepo.cartId = cartId.rawValue
                completion(.success)
            }
        }.resume()
    }

    func fetchCart(by id: String, completion: @escaping (Result<Storefront.Cart, Error>) -> Void) {
        let query = Storefront.buildQuery {
            $0.cart(id: .init(rawValue: id)) {
                $0.id()
                $0.totalQuantity()
                $0.cost {
                    $0.subtotalAmount {
                        $0.amount()
                    }
                    $0.totalAmount {
                        $0.amount()
                    }
                }
                $0.lines(first: 100) {
                    $0.nodes {
                        $0.id()
                        $0.quantity()
                        $0.cost {
                            $0.subtotalAmount {
                                $0.amount()
                            }
                            $0.totalAmount {
                                $0.amount()
                            }
                            $0.amountPerQuantity {
                                $0.amount()
                            }
                        }
                        $0.merchandise {
                            $0.onProductVariant {
                                $0.id()
                                $0.title()
                                $0.price {
                                    $0.amount()
                                }
                                $0.quantityAvailable()
                                $0.product {
                                    $0.title()
                                    $0.featuredImage {
                                        $0.url()
                                    }
                                }
                            }
                        }
                    }
                }
                $0.discountCodes {
                    $0.code()
                    $0.applicable()
                }
                $0.discountAllocations {
                    $0.discountedAmount {
                        $0.amount()
                    }
                    $0.discountApplication {
                        $0.value {
                            $0.onPricingPercentageValue {
                                $0.percentage()
                            }
                            $0.onMoneyV2 {
                                $0.amount()
                            }
                        }
                    }
                }
            }
        }

        service.client.queryGraphWith(query) { response, error in
            if let cart = response?.cart {
                completion(.success(cart))
            } else {
                completion(.failure(error ?? .noData))
            }
        }.resume()
    }

    func addItem(to cartId: String, variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        let lineItem = Storefront.CartLineInput.create(merchandiseId: .init(rawValue: variantId), quantity: .value(Int32(quantity)))

        let mutation = Storefront.buildMutation {
            $0.cartLinesAdd(cartId: .init(rawValue: cartId), lines: [lineItem]) {
                $0.cart {
                    $0.id()
                }
                $0.userErrors {
                    $0.message()
                }
            }
        }

        service.client.mutateGraphWith(mutation) { response, error in
            if let errors = response?.cartLinesAdd?.userErrors, !errors.isEmpty {
                let messages = errors.compactMap { $0.message }.joined(separator: ", ")
                completion(.errorMessage(messages))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }.resume()
    }

    func updateItemQuantity(cartId: String, lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        let updateInput = Storefront.CartLineUpdateInput.create(
            id: .init(rawValue: lineItemId),
            quantity: .value(Int32(quantity))
        )

        let mutation = Storefront.buildMutation {
            $0.cartLinesUpdate(cartId: .init(rawValue: cartId), lines: [updateInput]) {
                $0.cart {
                    $0.id()
                }
                $0.userErrors {
                    $0.message()
                }
            }
        }

        service.client.mutateGraphWith(mutation) { response, error in
            if let errors = response?.cartLinesUpdate?.userErrors, !errors.isEmpty {
                let messages = errors.compactMap { $0.message }.joined(separator: ", ")
                completion(.errorMessage(messages))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }.resume()
    }

    func removeItem(cartId: String, lineItemId: String, completion: @escaping (CartOperationResponse) -> Void) {
        let mutation = Storefront.buildMutation {
            $0.cartLinesRemove(cartId: .init(rawValue: cartId), lineIds: [.init(rawValue: lineItemId)]) {
                $0.cart {
                    $0.id()
                }
                $0.userErrors {
                    $0.message()
                }
            }
        }

        service.client.mutateGraphWith(mutation) { response, error in
            if let errors = response?.cartLinesRemove?.userErrors, !errors.isEmpty {
                let messages = errors.compactMap { $0.message }.joined(separator: ", ")
                completion(.errorMessage(messages))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }.resume()
    }

    func addDiscountCode(cartId: String, code: String, completion: @escaping (CartOperationResponse) -> Void) {
        let mutation = Storefront.buildMutation {
            $0.cartDiscountCodesUpdate(cartId: .init(rawValue: cartId), discountCodes: [code]) {
                $0.cart {
                    $0.discountCodes {
                        $0.applicable()
                    }
                }
                $0.userErrors {
                    $0.message()
                }
            }
        }
        service.client.mutateGraphWith(mutation) { response, error in
            if let errors = response?.cartDiscountCodesUpdate?.userErrors, !errors.isEmpty {
                let messages = errors.compactMap { $0.message }.joined(separator: ", ")
                completion(.errorMessage(messages))
            } else if let error = error {
                completion(.failure(error))
            } else if response?.cartDiscountCodesUpdate?.cart?.discountCodes.first?.applicable == false {
                completion(.errorMessage("Discount code not applicable."))
            } else {
                completion(.success)
            }
        }.resume()
    }
}
