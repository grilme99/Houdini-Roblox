/// This module converts internal `hapi-rs` types into serializable types. It is
/// quite verbose, but it is necessary for serializing asset info in HTTP
/// responses.

use hapi_rs::{
    parameter::{ParmBaseTrait, ParmInfo},
    session::{Parameter, ParmType},
};
use serde::Serialize;
use thiserror::Error;

#[derive(Debug, Error, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum AssetParamError {
    #[error("Failed to get current parameter value")]
    GetCurrent,
}

#[derive(Debug, Serialize)]
#[serde(tag = "type")]
pub enum ParamValue {
    Int { current: Vec<i32> },
    Menu { choices: Vec<String>, current: i32 },
    Toggle { current: bool },
    Float { current: Vec<f32> },
    String { current: Vec<String> },
    NoDefault,
}

impl From<hapi_rs::asset::ParmValue<'_>> for ParamValue {
    fn from(value: hapi_rs::asset::ParmValue) -> Self {
        match value {
            hapi_rs::asset::ParmValue::Int(v) => Self::Int { current: v.into() },
            hapi_rs::asset::ParmValue::Float(v) => Self::Float { current: v.into() },
            hapi_rs::asset::ParmValue::String(v) => Self::String { current: v.into() },
            hapi_rs::asset::ParmValue::Toggle(v) => Self::Toggle { current: v },
            hapi_rs::asset::ParmValue::NoDefault => Self::NoDefault,
        }
    }
}

#[derive(Debug, Serialize)]
pub enum ParamType {
    Int,
    MultiParmList,
    Toggle,
    Button,
    Float,
    Color,
    String,
    PathFile,
    PathFileGeo,
    PathFileImage,
    Node,
    FolderList,
    FolderListRadio,
    Folder,
    Label,
    Separator,
    PathFileDir,
    Max,
}

impl From<hapi_rs::geometry::ParmType> for ParamType {
    fn from(value: hapi_rs::geometry::ParmType) -> Self {
        match value {
            hapi_rs::geometry::ParmType::Int => Self::Int,
            hapi_rs::geometry::ParmType::Multiparmlist => Self::MultiParmList,
            hapi_rs::geometry::ParmType::Toggle => Self::Toggle,
            hapi_rs::geometry::ParmType::Button => Self::Button,
            hapi_rs::geometry::ParmType::Float => Self::Float,
            hapi_rs::geometry::ParmType::Color => Self::Color,
            hapi_rs::geometry::ParmType::String => Self::String,
            hapi_rs::geometry::ParmType::PathFile => Self::PathFile,
            hapi_rs::geometry::ParmType::PathFileGeo => Self::PathFileGeo,
            hapi_rs::geometry::ParmType::PathFileImage => Self::PathFileImage,
            hapi_rs::geometry::ParmType::Node => Self::Node,
            hapi_rs::geometry::ParmType::Folderlist => Self::FolderList,
            hapi_rs::geometry::ParmType::FolderlistRadio => Self::FolderListRadio,
            hapi_rs::geometry::ParmType::Folder => Self::Folder,
            hapi_rs::geometry::ParmType::Label => Self::Label,
            hapi_rs::geometry::ParmType::Separator => Self::Separator,
            hapi_rs::geometry::ParmType::PathFileDir => Self::PathFileDir,
            hapi_rs::geometry::ParmType::Max => Self::Max,
            _ => unreachable!("Unknown parameter type"),
        }
    }
}

#[derive(Debug, Serialize)]
pub enum Permissions {
    NonApplicable,
    ReadWrite,
    ReadOnly,
    WriteOnly,
    PermissionsMax,
}

impl From<hapi_rs::geometry::Permissions> for Permissions {
    fn from(value: hapi_rs::geometry::Permissions) -> Self {
        match value {
            hapi_rs::geometry::Permissions::NonApplicable => Self::NonApplicable,
            hapi_rs::geometry::Permissions::ReadWrite => Self::ReadWrite,
            hapi_rs::geometry::Permissions::ReadOnly => Self::ReadOnly,
            hapi_rs::geometry::Permissions::WriteOnly => Self::WriteOnly,
            hapi_rs::geometry::Permissions::PermissionsMax => Self::PermissionsMax,
            _ => unreachable!("Unknown permissions"),
        }
    }
}

#[derive(Debug, Serialize)]
pub enum ChoiceListType {
    None,
    Normal,
    Mini,
    Replace,
    Toggle,
}

impl From<hapi_rs::geometry::ChoiceListType> for ChoiceListType {
    fn from(value: hapi_rs::geometry::ChoiceListType) -> Self {
        match value {
            hapi_rs::geometry::ChoiceListType::None => Self::None,
            hapi_rs::geometry::ChoiceListType::Normal => Self::Normal,
            hapi_rs::geometry::ChoiceListType::Mini => Self::Mini,
            hapi_rs::geometry::ChoiceListType::Replace => Self::Replace,
            hapi_rs::geometry::ChoiceListType::Toggle => Self::Toggle,
            _ => unreachable!("Unknown choice list type"),
        }
    }
}

#[derive(Debug, Serialize)]
pub enum NodeType {
    Any,
    None,
    Obj,
    Sop,
    Chop,
    Rop,
    Shop,
    Cop,
    Vop,
    Dop,
    Top,
}

impl From<hapi_rs::node::NodeType> for NodeType {
    fn from(value: hapi_rs::node::NodeType) -> Self {
        match value {
            hapi_rs::node::NodeType::Any => Self::Any,
            hapi_rs::node::NodeType::None => Self::None,
            hapi_rs::node::NodeType::Obj => Self::Obj,
            hapi_rs::node::NodeType::Sop => Self::Sop,
            hapi_rs::node::NodeType::Chop => Self::Chop,
            hapi_rs::node::NodeType::Rop => Self::Rop,
            hapi_rs::node::NodeType::Shop => Self::Shop,
            hapi_rs::node::NodeType::Cop => Self::Cop,
            hapi_rs::node::NodeType::Vop => Self::Vop,
            hapi_rs::node::NodeType::Dop => Self::Dop,
            hapi_rs::node::NodeType::Top => Self::Top,
            _ => unreachable!("Unknown node type"),
        }
    }
}

#[derive(Debug, Serialize)]
pub enum NodeFlags {
    Any,
    None,
    Display,
    Render,
    Templated,
    Locked,
    Editable,
    Bypass,
    Network,
    Geometry,
    Camera,
    Light,
    Subnet,
    Curve,
    Guide,
    NonScheduler,
    NonBypass,
}

impl From<hapi_rs::node::NodeFlags> for NodeFlags {
    fn from(value: hapi_rs::node::NodeFlags) -> Self {
        match value {
            hapi_rs::node::NodeFlags::Any => Self::Any,
            hapi_rs::node::NodeFlags::None => Self::None,
            hapi_rs::node::NodeFlags::Display => Self::Display,
            hapi_rs::node::NodeFlags::Render => Self::Render,
            hapi_rs::node::NodeFlags::Templated => Self::Templated,
            hapi_rs::node::NodeFlags::Locked => Self::Locked,
            hapi_rs::node::NodeFlags::Editable => Self::Editable,
            hapi_rs::node::NodeFlags::Bypass => Self::Bypass,
            hapi_rs::node::NodeFlags::Network => Self::Network,
            hapi_rs::node::NodeFlags::Geometry => Self::Geometry,
            hapi_rs::node::NodeFlags::Camera => Self::Camera,
            hapi_rs::node::NodeFlags::Light => Self::Light,
            hapi_rs::node::NodeFlags::Subnet => Self::Subnet,
            hapi_rs::node::NodeFlags::Curve => Self::Curve,
            hapi_rs::node::NodeFlags::Guide => Self::Guide,
            hapi_rs::node::NodeFlags::Nonscheduler => Self::NonScheduler,
            hapi_rs::node::NodeFlags::NonBypass => Self::NonBypass,
            _ => unreachable!("Unknown node flags"),
        }
    }
}

#[derive(Debug, Serialize)]
pub enum RampType {
    Invalid,
    Float,
    Color,
    Max,
}

impl From<hapi_rs::geometry::RampType> for RampType {
    fn from(value: hapi_rs::geometry::RampType) -> Self {
        match value {
            hapi_rs::geometry::RampType::Invalid => Self::Invalid,
            hapi_rs::geometry::RampType::Float => Self::Float,
            hapi_rs::geometry::RampType::Color => Self::Color,
            hapi_rs::geometry::RampType::Max => Self::Max,
            _ => unreachable!("Unknown ramp type"),
        }
    }
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SerializableParamInfo {
    pub id: i32,
    pub parent_id: i32,
    pub child_index: i32,
    pub param_type: ParamType,
    pub permissions: Permissions,
    pub tag_count: i32,
    pub size: i32,
    pub choice_count: i32,
    pub choice_list_type: ChoiceListType,
    pub min: Option<f32>,
    pub max: Option<f32>,
    pub ui_min: Option<f32>,
    pub ui_max: Option<f32>,
    pub invisible: bool,
    pub disabled: bool,
    pub spare: bool,
    pub join_next: bool,
    pub label_none: bool,
    pub int_values_index: i32,
    pub float_values_index: i32,
    pub string_values_index: i32,
    pub choice_index: i32,
    pub input_node_type: NodeType,
    pub input_node_flag: NodeFlags,
    pub is_child_of_multi_param: bool,
    pub ramp_type: RampType,
    pub name: Option<String>,
    pub label: Option<String>,
    pub template_name: Option<String>,
    pub help: Option<String>,
}

impl From<&ParmInfo> for SerializableParamInfo {
    fn from(value: &ParmInfo) -> Self {
        Self {
            id: value.id().0,
            parent_id: value.parent_id().0,
            child_index: value.child_index(),
            param_type: value.parm_type().into(),
            permissions: value.permissions().into(),
            tag_count: value.tag_count(),
            size: value.size(),
            choice_count: value.choice_count(),
            choice_list_type: value.choice_list_type().into(),
            min: if value.has_min() {
                Some(value.min())
            } else {
                None
            },
            max: if value.has_max() {
                Some(value.max())
            } else {
                None
            },
            ui_min: if value.has_uimin() {
                Some(value.uimin())
            } else {
                None
            },
            ui_max: if value.has_uimax() {
                Some(value.uimax())
            } else {
                None
            },
            invisible: value.invisible(),
            disabled: value.disabled(),
            spare: value.spare(),
            join_next: value.join_next(),
            label_none: value.label_none(),
            int_values_index: value.int_values_index(),
            float_values_index: value.float_values_index(),
            string_values_index: value.string_values_index(),
            choice_index: value.choice_index(),
            input_node_type: value.input_node_type().into(),
            input_node_flag: value.input_node_flag().into(),
            is_child_of_multi_param: value.is_child_of_multi_parm(),
            ramp_type: value.ramp_type().into(),
            name: value.name().ok(),
            label: value.label().ok(),
            template_name: value.template_name().ok(),
            help: value.help().ok(),
        }
    }
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SerializableParameter {
    pub current_value: ParamValue,
    pub info: SerializableParamInfo,
}

impl TryFrom<Parameter> for SerializableParameter {
    type Error = AssetParamError;

    fn try_from(param: Parameter) -> Result<Self, Self::Error> {
        let param_type = param.info().parm_type();
        let current_value = match &param {
            Parameter::Button(_) => ParamValue::NoDefault,
            Parameter::Float(param) => ParamValue::Float {
                current: param.get_array().map_err(|_| AssetParamError::GetCurrent)?,
            },
            Parameter::Int(param) => {
                if param_type == ParmType::Toggle {
                    let current = param.get(0).map_err(|_| AssetParamError::GetCurrent)? > 0;
                    ParamValue::Toggle { current }
                } else if let Ok(Some(menu)) = param.menu_items() {
                    let choices: Vec<String> = menu
                        .into_iter()
                        .map(|choice| choice.label().unwrap())
                        .collect();
                    let current = param.get(0).map_err(|_| AssetParamError::GetCurrent)?;

                    ParamValue::Menu { choices, current }
                } else {
                    ParamValue::Int {
                        current: param.get_array().map_err(|_| AssetParamError::GetCurrent)?,
                    }
                }
            }
            Parameter::String(param) => ParamValue::String {
                current: param.get_array().map_err(|_| AssetParamError::GetCurrent)?,
            },
            Parameter::Other(_) => ParamValue::NoDefault,
        };

        Ok(Self {
            current_value,
            info: param.info().into(),
        })
    }
}
