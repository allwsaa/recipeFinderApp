//
//  FilterViewController.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

import UIKit
import SnapKit

protocol FilterViewControllerDelegate: AnyObject {
    func applyFilters(filters: [String: String])
}

class FilterViewController: UIViewController {
    weak var delegate: FilterViewControllerDelegate?
    private var filters: [String: String] = [:]

    private let dietSegmentedControl = UISegmentedControl(items: ["None", "Vegan", "Vegetarian"])
    private let glutenFreeSwitch = UISwitch()
    private let sugarFreeSwitch = UISwitch()
    private let applyFiltersButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Filters"

        let glutenFreeLabel = UILabel()
        glutenFreeLabel.text = "Gluten-Free"
        let sugarFreeLabel = UILabel()
        sugarFreeLabel.text = "Sugar-Free"

        applyFiltersButton.setTitle("Show Filtered Recipes", for: .normal)
        applyFiltersButton.setTitleColor(.white, for: .normal)
        applyFiltersButton.backgroundColor = .systemBlue
        applyFiltersButton.layer.cornerRadius = 8
        applyFiltersButton.addTarget(self, action: #selector(applyFiltersAction), for: .touchUpInside)

        view.addSubview(dietSegmentedControl)
        view.addSubview(glutenFreeLabel)
        view.addSubview(glutenFreeSwitch)
        view.addSubview(sugarFreeLabel)
        view.addSubview(sugarFreeSwitch)
        view.addSubview(applyFiltersButton)

        dietSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        glutenFreeLabel.snp.makeConstraints { make in
            make.top.equalTo(dietSegmentedControl.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        glutenFreeSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(glutenFreeLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        sugarFreeLabel.snp.makeConstraints { make in
            make.top.equalTo(glutenFreeLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        sugarFreeSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(sugarFreeLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        applyFiltersButton.snp.makeConstraints { make in
            make.top.equalTo(sugarFreeLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }

    @objc private func applyFiltersAction() {
        switch dietSegmentedControl.selectedSegmentIndex {
        case 1:
            filters["diet"] = "vegan"
        case 2:
            filters["diet"] = "vegetarian"
        default:
            filters["diet"] = nil
        }

        if glutenFreeSwitch.isOn {
            filters["intolerances"] = "gluten"
        }
        if sugarFreeSwitch.isOn {
            filters["intolerances"] = (filters["intolerances"] ?? "") + ",sugar"
        }

        delegate?.applyFilters(filters: filters)
        navigationController?.popViewController(animated: true)
    }
}
