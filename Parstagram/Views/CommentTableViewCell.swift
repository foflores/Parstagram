//  CommentTableViewCell.swift
//  Parstagram
//
//  Created by Favian Flores on 3/14/21.

import UIKit

class CommentTableViewCell: UITableViewCell {
	@IBOutlet weak var commentLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var profileImage: UIImageView!


	override func awakeFromNib() {
		super.awakeFromNib()
		profileImage.layer.cornerRadius = 15
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}
