//
//  RecipeCell.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

import UIKit
import SnapKit

class RecipeCell: UITableViewCell {
    private let recipeImageView = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(recipeImageView)
        contentView.addSubview(titleLabel)

        // Настройка изображения
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 12
        recipeImageView.layer.masksToBounds = true
        recipeImageView.backgroundColor = .systemGray6 // Легкий фон для красоты

        // Настройка текста
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        // Расположение элементов
        recipeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10) // Отступ сверху
            make.centerX.equalToSuperview() // Центр по горизонтали
            make.height.equalTo(120) // Высота картинки
            make.width.equalTo(200) // Ширина картинки
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(recipeImageView.snp.bottom).offset(10) // Отступ от картинки
            make.leading.trailing.equalToSuperview().inset(15) // Отступы от краев
            make.bottom.equalToSuperview().offset(-10) // Отступ снизу
        }
    }

    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.title
        recipeImageView.image = nil // Сброс изображения перед использованием

        if let url = URL(string: recipe.image) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.recipeImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
