//
//  FilterViewController.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

import UIKit
import SnapKit

protocol FilterViewControllerDelegate: AnyObject {
    func applyFilters(filters: [String: String], sortOption: String?)
}

class FilterViewController: UIViewController {
    weak var delegate: FilterViewControllerDelegate?
    private var filters: [String: String] = [:]
    private var sortOption: String?


    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Refine your search with filters"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()

    private let dietSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            UIImage(systemName: "xmark") ?? "None",
            UIImage(systemName: "leaf") ?? "Vegan",
            UIImage(systemName: "heart") ?? "Vegetarian"
        ])
        control.selectedSegmentIndex = 0
        return control
    }()

    private let glutenFreeSwitch: UISwitch = {
        let glutenSwitch = UISwitch()
        return glutenSwitch
    }()

    private let sugarFreeSwitch: UISwitch = {
        let sugarSwitch = UISwitch()
        return sugarSwitch
    }()

    private let sortSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            "None",
            "Cooking Time",
            "Calories"
        ])
        control.selectedSegmentIndex = 0
        return control
    }()

    private let glutenFreeLabel: UILabel = {
        let label = UILabel()
        label.text = "Gluten-Free"
        return label
    }()

    private let sugarFreeLabel: UILabel = {
        let label = UILabel()
        label.text = "Sugar-Free"
        return label
    }()

    private let sortLabel: UILabel = {
        let label = UILabel()
        label.text = "Sort By"
        return label
    }()

    private let applyFiltersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Filtered Recipes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(applyFiltersAction), for: .touchUpInside)
        return button
    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Filters"

    
        view.addSubview(headerLabel)
        view.addSubview(dietSegmentedControl)
        view.addSubview(glutenFreeLabel)
        view.addSubview(glutenFreeSwitch)
        view.addSubview(sugarFreeLabel)
        view.addSubview(sugarFreeSwitch)
        view.addSubview(sortLabel)
        view.addSubview(sortSegmentedControl)
        view.addSubview(applyFiltersButton)

    
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

  
        dietSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(20)
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

        
        sortLabel.snp.makeConstraints { make in
            make.top.equalTo(sugarFreeLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
        }

        sortSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(sortLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        applyFiltersButton.snp.makeConstraints { make in
            make.top.equalTo(sortSegmentedControl.snp.bottom).offset(30)
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


        var intolerances: [String] = []
        if glutenFreeSwitch.isOn {
            intolerances.append("gluten")
        }
        if sugarFreeSwitch.isOn {
            intolerances.append("sugar")
        }
        filters["intolerances"] = intolerances.joined(separator: ",")


        switch sortSegmentedControl.selectedSegmentIndex {
        case 1:
            sortOption = "cookingTime"
        case 2:
            sortOption = "calories"
        default:
            sortOption = nil
        }


        UIView.animate(withDuration: 0.2, animations: {
            self.applyFiltersButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.applyFiltersButton.transform = .identity
            }
        }

        delegate?.applyFilters(filters: filters, sortOption: sortOption)
        navigationController?.popViewController(animated: true)
    }
}
