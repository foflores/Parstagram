//  PostTableViewCell.swift
//  Parstagram
//
//  Created by Favian Flores on 3/6/21.

import UIKit

class PostTableViewCell: UITableViewCell {
	@IBOutlet weak var postImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var profileImage: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		profileImage.layer.cornerRadius = 25
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		postImage.image = nil
		nameLabel.text = nil
		descriptionLabel.text = nil
		dateLabel.text = nil
	}
}
