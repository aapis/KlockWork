import SwiftUI

public enum ActivityMode: CaseIterable {
    case byEntity, byDate

    var id: Int {
        switch self {
        case .byEntity: return 1
        default: return 0
        }
    }

    var helpText: String {
        switch self {
        case .byDate: return "Timeline will be based on selected date"
        case .byEntity: return "Timeline will be based on selected entities"
        }
    }

    var icon: String {
        switch self {
        case .byEntity: return "rectangle.on.rectangle.dashed"
        default: return "calendar"
        }
    }

    var labelText: String {
        switch self {
        case .byEntity: return "By Entity"
        case .byDate: return "By Date"
        }
    }

    var view: AnyView {
        switch self {
        case .byEntity: return AnyView(ModeByEntity())
        default: return AnyView(ModeByDate())
        }
    }

    var button: ToolbarButton {
        ToolbarButton(
            id: self.id,
            helpText: self.helpText,
            icon: self.icon,
            labelText: self.labelText,
            contents: self.view
        )
    }
}
