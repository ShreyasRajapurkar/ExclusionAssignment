import UIKit
import DLRadioButton

class FacilityCell: UICollectionViewCell {
    let titleLabel: UILabel
    var optionsView: UIStackView
    var viewModel: FacilityCellViewModel?
    var currentSelectedButtonTag: Int? = nil
    var cellViewModel: FacilityCellViewModel?
    weak var exclusionDelegate: ExclusionHandler? = nil
    
    override init(frame: CGRect) {
        titleLabel = UILabel()
        optionsView = UIStackView()
        super.init(frame: frame)

        setupSubviews()
        setupLayout()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setup(cellViewModel: FacilityCellViewModel, exclusionDelegate: ExclusionHandler) {
        self.exclusionDelegate = exclusionDelegate
        self.cellViewModel = cellViewModel
        titleLabel.text = cellViewModel.title
        titleLabel.textColor = UIColor.black
        
        for (index, option) in cellViewModel.options.enumerated() {
            createAndSetupRadioButton(index: index, option: option)
        }

        self.currentSelectedButtonTag = cellViewModel.selectedButtonTag
        
        optionsView.arrangedSubviews.map { view in
            guard let radioButton = view as? DLRadioButton else {
                return
            }

            if cellViewModel.disabledButtons.keys.contains(radioButton.tag) {
                guard let buttonCounter = cellViewModel.disabledButtons[radioButton.tag] else {
                    assert(true, "Every radio button must have an associated counter")
                    return
                }

                if buttonCounter > 0 {
                    disableRadioButton(button: radioButton)
                } else {
                    enableRadioButton(button: radioButton)
                }
            }

            if cellViewModel.selectedButtonTag == view.tag {
                radioButton.isSelected = true
                radioButton.setTitleColor(UIColor.green, for: .normal)
            }
        }
    }

    private func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(optionsView)
    }

    private func setupLayout() {
        optionsView.axis = .vertical
        optionsView.spacing = 20
        optionsView.alignment = .fill
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        optionsView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()

        constraints.append(titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(optionsView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10))
        constraints.append(optionsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor))
        constraints.append(optionsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor))
        constraints.append(optionsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
    
        NSLayoutConstraint.activate(constraints)
    }

    @objc
    func resolveExclusionsIfNeeded(radioButton: DLRadioButton) {
        if let cellViewModel = cellViewModel {
            exclusionDelegate?.resolveExclusionsIfNeeded(facilityId: cellViewModel.facilityId, optionId: radioButton.tag, previousOption: currentSelectedButtonTag)
        }
    }

    private func disableRadioButton(button: UIButton) {
        button.setTitleColor(UIColor.white.withAlphaComponent(0.2), for: .normal)
        button.isUserInteractionEnabled = false
    }
    
    private func enableRadioButton(button: UIButton) {
        button.setTitleColor(UIColor.white, for: .normal)
        button.isUserInteractionEnabled = true
    }
    
    private func createAndSetupRadioButton(index: Int, option: Option) {
        var otherGroup = [DLRadioButton]()
        // Need a reference to first button to set the radio group
        var firstRadioButton: DLRadioButton?

        let radioButton = DLRadioButton()
        radioButton.isSelected = false
        radioButton.addTarget(self, action: #selector(resolveExclusionsIfNeeded), for: .touchUpInside)
        radioButton.isMultipleSelectionEnabled = false
        radioButton.setTitle(option.name, for: .normal)
        if let tag = Int(option.id) {
            radioButton.tag = tag
        }

        let image = UIImage(named: option.icon) ?? UIImage()
        radioButton.icon = image
        radioButton.iconSelected = image.withTintColor(UIColor.green)
        optionsView.addArrangedSubview(radioButton)

        if index == 0 {
            firstRadioButton = radioButton
        } else {
            otherGroup.append(radioButton)
        }

        // Set the other buttons - this defines the radio button group
        firstRadioButton?.otherButtons = otherGroup
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        optionsView.subviews.map { $0.removeFromSuperview() }
    }
}
