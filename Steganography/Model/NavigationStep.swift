//
//  NavigationStep.swift
//  Steganography
//
//  Created by 김수아 on 12/5/24.
//

enum NavigationStep<Step>{
    case clear
    case pop
    case next(Step)
}
