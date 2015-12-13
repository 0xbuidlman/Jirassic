//
//  User.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

struct User {

	var isLoggedIn: Bool
	var password: String?
	var email: String?
}

typealias LoginCredentials = (email: String, password: String)
