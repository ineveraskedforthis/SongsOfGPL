"""
Code generator of Songs of GPL data manager.
Creates properly typed LUA bindings for these arrays.
Handles (de)serialisation routines.
"""
from __future__ import annotations

import typing
import random

# pylint: disable=locally-disabled, multiple-statements, fixme, line-too-long, too-many-lines, f-string-without-interpolation

REGISTERED_NAMES: typing.Dict[str, EntityDescription] = {}
REGISTERED_ENUMS: typing.Dict[str, StaticEntityDescription] = {}
REGISTERED_ID_NAMES = {}

REGISTERED_STRUCTS: typing.Dict[str, StructDescription] = {}

# retrieve list of names of entity linked to a given name and name of according field
REGISTERED_LINKS: typing.Dict[str, typing.List[typing.Tuple[str, str]]] = {}

DESCRIPTION_PATH = "./sote/codegen/description"
DESCRIPTION_RAWS_PATH = "./sote/codegen/description_raws"
DESCRIPTION_STATIC_PATH = "./sote/codegen/description_static"
DESCRIPTION_STRUCTS_PATH = "./sote/codegen/description_structs"
OUTPUT_PATH = "./sote/codegen/output/generated.lua"
DCON_DESC_PATH = "./sote/codegen/dcon/sote.txt"
CPP_COMMON_TYPES_PATH = "./sote/codegen/dcon/common_types.hpp"
NAMESPACE = "DATA"
SAVE_FILE_NAME_LUA = "gamestatesave.bitserbeaver"
SAVE_FILE_NAME_FFI = "gamestatesave.binbeaver"

def prefix_to_id_name(prefix: str):
    """
    Returns symbol for id for given prefix
    """

    return f'{prefix}_id'

class Atom:
    """
    Represents types which do not have internal structural division
    """
    c_type: str
    lsp_type: str
    dcon_type: str
    default_value: typing.Union[None, str]
    generated_during_runtime: bool
    ignore_in_data_layout: bool

    def __init__(self, description: str) -> None:
        # if description == "trade_good":
        #     print(description)
        self.ignore_in_data_layout = False
        self.generated_during_runtime = False

        if description.startswith('@'):
            self.generated_during_runtime = True
            description = description[1:]
        if description.startswith('#'):
            self.ignore_in_data_layout = True
            description = description[1:]

        l = description.split("=")
        if len(l) > 1:
            self.default_value = l[1]
        else:
            self.default_value = None

        description = l[0]

        # print(1)
        if description in REGISTERED_ENUMS:
            self.c_type = "uint8_t"
            self.lsp_type = description
            self.dcon_type = "base_types::" + description
            return
        # print(2)
        if description in ["uint32_t", "int32_t", "float", "uint16_t", "uint8_t"]:
            self.c_type = description
            self.lsp_type = "number"
            self.dcon_type = description
            return
        # print(3)
        if description == "bool":
            self.c_type = "bool"
            self.lsp_type = "boolean"
            self.dcon_type = "bitfield"
            return
        # print(4)
        if description in REGISTERED_ID_NAMES:
            self.c_type = "uint32_t"
            self.lsp_type = description
            self.dcon_type = description
            return
        # print(5)
        if description in REGISTERED_NAMES:
            self.c_type = "uint32_t"
            self.lsp_type = prefix_to_id_name(description)
            self.dcon_type = prefix_to_id_name(description)
            return
        # print(6)
        if description in REGISTERED_STRUCTS:
            self.c_type = description
            self.lsp_type = "struct_" + description
            self.dcon_type = "base_types::" + description
            return
        # print(7)
        # if everything fails:
        # give up

        self.c_type = None
        self.lsp_type = description
        self.dcon_type = None

        # raise(RuntimeError("INVALID ATOMIC TYPE"))

    def generate_value(self):
        """
        Generates a random value for this field for testing purposes
        """

        if self.lsp_type in REGISTERED_ENUMS:
            max_count = REGISTERED_ENUMS[self.lsp_type].max_count
            return random.randint(0, max_count - 2)

        if self.lsp_type == "string":
            return '"random.randint(0, 1000)"'

        if self.c_type == "bool":
            if random.randint(0, 1) == 0:
                return "true"
            else:
                return "false"

        if self.c_type == "float":
            return random.randint(-20, 20)

        if self.c_type == "int32_t":
            return random.randint(-20, 20)

        if self.c_type in ("uint32_t", "uint16_t", "uint8_t"):
            return random.randint(0, 20)



class Field:
    """
    Description of a property
    """
    prefix: str
    name: str
    description: str

    value: Atom
    array_size: int
    index: Atom

    def __init__(self, prefix, name, field_type, description, array_size = 1, index_type = "uint32_t") -> None:
        self.prefix = prefix
        self.name = name
        self.array_size = int(array_size)

        self.value = Atom(field_type)
        self.index = Atom(index_type)

        self.description = description

    def array_name(self):
        """
        Returns a name of to array with this field
        """
        return f'{self.prefix}_{self.name}'

    def local_var_name(self):
        """
        Returns a name of local variable responsible for pointer to array with this field
        """
        return f'{NAMESPACE}.{self.array_name()}'

    def getter_name(self):
        """
        Returns a name of a getter
        """
        return f"{NAMESPACE}.{self.prefix}_get_{self.name}"

    def setter_name(self):
        """
        Returns a name of a setter
        """
        return f"{NAMESPACE}.{self.prefix}_set_{self.name}"

    def increment_name(self):
        """
        Returns a name of a incrementer
        """
        return f"{NAMESPACE}.{self.prefix}_inc_{self.name}"

    def lua_getter(self):
        """
        Returns a string with getter binding
        """
        if self.value.ignore_in_data_layout:
            return ""

        arg = prefix_to_id_name(self.prefix)
        if self.value.c_type:
            if self.array_size == 1:
                if self.value.c_type in REGISTERED_STRUCTS:
                    result = ""
                    struct = REGISTERED_STRUCTS[self.value.c_type]
                    for field in struct.fields:
                        result += \
                        f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@return {field.value.lsp_type} {self.name} {self.description}\n" \
                        f"function {self.getter_name()}_{field.name}({arg})\n" \
                        f"    return {NAMESPACE}.{self.prefix}[{arg}].{self.name}.{field.name}\n" \
                        f"end\n"
                    return result
                return  f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@return {self.value.lsp_type} {self.name} {self.description}\n" \
                        f"function {self.getter_name()}({arg})\n" \
                        f"    return {NAMESPACE}.{self.prefix}[{arg}].{self.name}\n" \
                        f"end\n"
            else:
                if self.value.c_type in REGISTERED_STRUCTS:
                    result = ""
                    struct = REGISTERED_STRUCTS[self.value.c_type]
                    for field in struct.fields:
                        result += \
                        f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@param index {self.index.lsp_type} valid\n" \
                        f"---@return {field.value.lsp_type} {self.name} {self.description}\n" \
                        f"function {self.getter_name()}_{field.name}({arg}, index)\n" \
                        f"    if {NAMESPACE}.{self.prefix}[{arg}].{self.name} == nil then return 0 end\n" \
                        f"    return {NAMESPACE}.{self.prefix}[{arg}].{self.name}[index].{field.name}\n" \
                        f"end\n"
                    return result
                return  f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@param index {self.index.lsp_type} valid\n" \
                        f"---@return {self.value.lsp_type} {self.name} {self.description}\n" \
                        f"function {self.getter_name()}({arg}, index)\n" \
                        f"    if {NAMESPACE}.{self.prefix}[{arg}].{self.name} == nil then return 0 end\n" \
                        f"    return {NAMESPACE}.{self.prefix}[{arg}].{self.name}[index]\n" \
                        f"end\n"
        else:
            if self.array_size > 1:
                return  f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@param index {self.index.lsp_type} valid\n" \
                        f"---@return {self.value.lsp_type} {self.name} {self.description}\n" \
                        f"function {self.getter_name()}({arg}, index)\n" \
                        f"    if {self.local_var_name()}[{arg}] == nil then return 0 end\n"\
                        f"    return {self.local_var_name()}[{arg}][index]\n" \
                        f"end\n"
            else:
                return  f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@return {self.value.lsp_type} {self.name} {self.description}\n" \
                        f"function {self.getter_name()}({arg})\n" \
                        f"    return {self.local_var_name()}[{arg}]\n" \
                        f"end\n"

    def lua_setter(self):
        """
        Returns a string with setter binding
        """
        if self.value.ignore_in_data_layout:
            return ""

        arg = prefix_to_id_name(self.prefix)
        if self.value.c_type:
            if self.array_size == 1:
                if self.value.c_type in REGISTERED_STRUCTS:
                    result = ""
                    struct = REGISTERED_STRUCTS[self.value.c_type]
                    for field in struct.fields:
                        result += \
                        f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@param value {field.value.lsp_type} valid {field.value.lsp_type}\n" \
                        f"function {self.setter_name()}_{field.name}({arg}, value)\n" \
                        f"    {NAMESPACE}.{self.prefix}[{arg}].{self.name}.{field.name} = value\n" \
                        f"end\n"
                        if field.value.lsp_type == "number":
                            result += \
                            f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                            f"---@param value {field.value.lsp_type} valid {field.value.lsp_type}\n" \
                            f"function {self.increment_name()}_{field.name}({arg}, value)\n" \
                            f"    {NAMESPACE}.{self.prefix}[{arg}].{self.name}.{field.name} = {NAMESPACE}.{self.prefix}[{arg}].{self.name}.{field.name} + value\n" \
                            f"end\n"
                    return result

                result =f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@param value {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                        f"function {self.setter_name()}({arg}, value)\n" \
                        f"    {NAMESPACE}.{self.prefix}[{arg}].{self.name} = value\n" \
                        f"end\n"
                if self.value.lsp_type == "number":
                    result +=   f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                                f"---@param value {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                                f"function {self.increment_name()}({arg}, value)\n" \
                                f"    {NAMESPACE}.{self.prefix}[{arg}].{self.name} = {NAMESPACE}.{self.prefix}[{arg}].{self.name} + value\n" \
                                f"end\n"
                return result
            else:
                if self.value.c_type in REGISTERED_STRUCTS:
                    result = ""
                    struct = REGISTERED_STRUCTS[self.value.c_type]
                    for field in struct.fields:
                        result += \
                        f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@param index {self.index.lsp_type} valid index\n" \
                        f"---@param value {field.value.lsp_type} valid {field.value.lsp_type}\n" \
                        f"function {self.setter_name()}_{field.name}({arg}, index, value)\n" \
                        f"    {NAMESPACE}.{self.prefix}[{arg}].{self.name}[index].{field.name} = value\n" \
                        f"end\n"
                        if field.value.lsp_type == "number":
                            result += f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                            f"---@param index {self.index.lsp_type} valid index\n" \
                            f"---@param value {field.value.lsp_type} valid {field.value.lsp_type}\n" \
                            f"function {self.increment_name()}_{field.name}({arg}, index, value)\n" \
                            f"    {NAMESPACE}.{self.prefix}[{arg}].{self.name}[index].{field.name} = {NAMESPACE}.{self.prefix}[{arg}].{self.name}[index].{field.name} + value\n" \
                            f"end\n"
                    return result
                result =f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@param index {self.index.lsp_type} valid index\n" \
                        f"---@param value {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                        f"function {self.setter_name()}({arg}, index, value)\n" \
                        f"    {NAMESPACE}.{self.prefix}[{arg}].{self.name}[index] = value\n" \
                        f"end\n"
                if self.value.lsp_type == "number":
                    result +=f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@param index {self.index.lsp_type} valid index\n" \
                        f"---@param value {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                        f"function {self.increment_name()}({arg}, index, value)\n" \
                        f"    {NAMESPACE}.{self.prefix}[{arg}].{self.name}[index] = {NAMESPACE}.{self.prefix}[{arg}].{self.name}[index] + value\n" \
                        f"end\n"
                return result
        else:
            if self.array_size > 1:
                return  f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@param index {self.index.lsp_type} valid index\n" \
                        f"---@param value {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                        f"function {self.setter_name()}({arg}, index, value)\n" \
                        f"    {self.local_var_name()}[{arg}][index] = value\n" \
                        f"end\n"
            else:
                return  f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                        f"---@param value {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                        f"function {self.setter_name()}({arg}, value)\n" \
                        f"    {self.local_var_name()}[{arg}] = value\n" \
                        f"end\n"

    def lua_bindings(self):
        """
        Returns a string with all according bindings
        """
        return f'{self.lua_getter()}{self.lua_setter()}'

    def array_string(self, max_count: int):
        """
        Generates description of tables
        """

    def struct_field(self):
        """
        Generates struct field for table
        """
        if self.value.ignore_in_data_layout:
            return ""
        if self.value.c_type:
            if self.array_size == 1:
                return f"        {self.value.c_type} {self.name};\n"
            else:
                return f"        {self.value.c_type} {self.name}[{self.array_size}];\n"

        return ""


class LinkField(Field):
    """
    Description of a link toward some object
    """
    prefix: str
    name: str
    type: str
    lsp_type: str
    description: str
    is_ctype: bool

    can_repeat: bool

    def array_string(self, max_count: int):
        if self.value.lsp_type in REGISTERED_ID_NAMES:
            return ""
        raise RuntimeError(f"Invalid link: {self.value.lsp_type} {self.name}")
        # lsp_table_type = f'---@type table<{prefix_to_id_name(self.prefix)}, {prefix_to_id_name(self.lsp_type)}>\n'
        # declaration = f'{self.local_var_name()}'
        # return lsp_table_type + declaration + '= {}\n'

    def local_accessor_symbol(self):
        """
        Generates symbol for accessor of relation from this field
        """
        return f'{self.prefix}_from_{self.name}'

    def get_from_function(self):
        """
        Generates name for accessor function of relation from this field
        """
        return f"{NAMESPACE}.get_{self.prefix}_from_{self.name}"

    def lua_getter(self):
        result = super().lua_getter()
        arg = self.name
        if self.can_repeat:
            result +=   f"---@param {arg} {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                        f"---@return {prefix_to_id_name(self.prefix)}[] An array of {self.prefix} \n" \
                        f"function {NAMESPACE}.get_{self.prefix}_from_{self.name}({arg})\n" \
                        f"    return {self.local_accessor_name()}[{arg}]\n"\
                        f"end\n"
            result +=   f"---@param {arg} {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                        f"---@param func fun(item: {prefix_to_id_name(self.prefix)}) valid {self.value.lsp_type}\n" \
                        f"function {NAMESPACE}.for_each_{self.prefix}_from_{self.name}({arg}, func)\n" \
                        f"    if {self.local_accessor_name()}[{arg}] == nil then return end\n"\
                        f"    for _, item in pairs({self.local_accessor_name()}[{arg}]) do func(item) end\n"\
                        f"end\n"
            result +=   f"---@param {arg} {self.value.lsp_type} valid {self.value.lsp_type}\n"
            result +=   f"---@param func fun(item: {prefix_to_id_name(self.prefix)}):boolean \n"
            result +=   f"---@return table<{prefix_to_id_name(self.prefix)}, {prefix_to_id_name(self.prefix)}> \n"
            result +=   f"function {NAMESPACE}.filter_array_{self.prefix}_from_{self.name}({arg}, func)\n"
            result +=   f"    ---@type table<{prefix_to_id_name(self.prefix)}, {prefix_to_id_name(self.prefix)}> \n"
            result +=    "    local t = {}\n"
            result +=   f"    if {self.local_accessor_name()}[{arg}] == nil then return t end\n"
            result +=   f"    for _, item in pairs({self.local_accessor_name()}[{arg}]) do\n"
            result +=    "        if func(item) then table.insert(t, item) end\n"
            result +=    "    end\n"
            result +=    "    return t\n"
            result +=    "end\n"
            result +=   f"---@param {arg} {self.value.lsp_type} valid {self.value.lsp_type}\n"
            result +=   f"---@param func fun(item: {prefix_to_id_name(self.prefix)}):boolean \n"
            result +=   f"---@return table<{prefix_to_id_name(self.prefix)}, {prefix_to_id_name(self.prefix)}> \n"
            result +=   f"function {NAMESPACE}.filter_{self.prefix}_from_{self.name}({arg}, func)\n"
            result +=   f"    ---@type table<{prefix_to_id_name(self.prefix)}, {prefix_to_id_name(self.prefix)}> \n"
            result +=    "    local t = {}\n"
            result +=   f"    if {self.local_accessor_name()}[{arg}] == nil then return t end\n"
            result +=   f"    for _, item in pairs({self.local_accessor_name()}[{arg}]) do\n"
            result +=    "        if func(item) then t[item] = item end\n"
            result +=    "    end\n"
            result +=    "    return t\n"
            result +=    "end\n"
        else:
            result +=   f"---@param {arg} {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                        f"---@return {prefix_to_id_name(self.prefix)} {self.prefix} \n" \
                        f"function {self.get_from_function()}({arg})\n" \
                        f"    if {self.local_accessor_name()}[{arg}] == nil then return 0 end\n"\
                        f"    return {self.local_accessor_name()}[{arg}]\n"\
                        f"end\n"
        return result

    def remove_key_func_name(self):
        """
        Returns a name of function which removes key from additional tables
        """
        s = f"__remove_key_{self.prefix}_{self.name}"
        return s.upper()

    def lua_setter(self):
        """
        Returns a string with setter binding
        """
        arg = prefix_to_id_name(self.prefix)
        if self.can_repeat:
            return  f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                    f"---@param old_value {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                    f"function {self.remove_key_func_name()}({arg}, old_value)\n" \
                    f"    local found_key = nil\n"\
                    f"    if {self.local_accessor_name()}[old_value] == nil then\n        {self.local_accessor_name()}[old_value] = {{}}\n        return\n    end\n" \
                    f"    for key, value in pairs({self.local_accessor_name()}[old_value]) do\n"\
                    f"        if value == {arg} then\n"\
                    f"            found_key = key\n"\
                    f"            break\n"\
                    f"        end\n"\
                    f"    end\n"\
                    f"    if found_key ~= nil then\n"\
                    f"        table.remove({self.local_accessor_name()}[old_value], found_key)\n"\
                    f"    end\n"\
                    f"end\n"\
                    f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                    f"---@param value {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                    f"function {self.setter_name()}({arg}, value)\n" \
                    f"    local old_value = {NAMESPACE}.{self.prefix}[{arg}].{self.name}\n"\
                    f"    {NAMESPACE}.{self.prefix}[{arg}].{self.name} = value\n" \
                    f"    {self.remove_key_func_name()}({arg}, old_value)\n"\
                    f"    if {self.local_accessor_name()}[value] == nil then {self.local_accessor_name()}[value] = {{}} end\n"\
                    f"    table.insert({self.local_accessor_name()}[value], {arg})\n"\
                    f"end\n"
        else:
            return  f"function {self.remove_key_func_name()}(old_value)\n" \
                    f"    {self.local_accessor_name()}[old_value] = nil\n"\
                    f"end\n"\
                    f"---@param {arg} {prefix_to_id_name(self.prefix)} valid {self.prefix} id\n" \
                    f"---@param value {self.value.lsp_type} valid {self.value.lsp_type}\n" \
                    f"function {self.setter_name()}({arg}, value)\n" \
                    f"    local old_value = {NAMESPACE}.{self.prefix}[{arg}].{self.name}\n"\
                    f"    {NAMESPACE}.{self.prefix}[{arg}].{self.name} = value\n" \
                    f"    {self.remove_key_func_name()}(old_value)\n"\
                    f"    {self.local_accessor_name()}[value] = {arg}\n"\
                    f"end\n"

    def local_accessor_name(self):
        """
        Returns a name of local variable responsible for pointer
        to array with accessor to the object from linked object
        """
        return f'{NAMESPACE}.{self.prefix}_from_{self.name}'

    def accessor_string(self):
        """
        String to access the link or links from an object
        """

        if self.can_repeat:
            lsp_table_type = f'---@type table<{self.value.lsp_type}, {prefix_to_id_name(self.prefix)}[]>>\n'
            declaration = f'{self.local_accessor_name()}'
            return lsp_table_type + declaration + '= {}\n'

        lsp_table_type = f'---@type table<{self.value.lsp_type}, {prefix_to_id_name(self.prefix)}>\n'
        declaration = f'{self.local_accessor_name()}'
        return lsp_table_type + declaration + '= {}\n'

    # def access_link_string(self):



class EntityField(Field):
    """
    Description of entity field
    """

    def array_string(self, max_count: int):
        """
        Used only for LUA arrays
        """
        if self.array_size == 1:
            lsp_table_type = f'---@type ({self.value.lsp_type})[]\n'
            declaration = f'{self.local_var_name()}'
        else:
            lsp_table_type = f'---@type (table<{self.index.lsp_type}, {self.value.lsp_type}>)[]\n'
            declaration = f'{self.local_var_name()}'

        if self.value.c_type:
            return lsp_table_type + declaration + f'= ffi.new("{self.value.c_type}[?]", {max_count})\n'
        else:
            return lsp_table_type + declaration + '= {}\n'

class StructDescription:
    """
    Handles declaration of structs
    """
    name: str
    fields: typing.List[EntityField]

    def __init__(self, name) -> None:
        self.name = name
        REGISTERED_STRUCTS[self.name] = self
        print("REGISTER STRUCT: ", self.name)
        STRUCTS_LIST.append(self)
        REGISTERED_STRUCTS[name] = self
        self.fields = []

        with open(f"{DESCRIPTION_STRUCTS_PATH}/{name}.txt", "r", encoding="utf8") as file:
            for line in file.readlines():
                line_splitted = line.strip().split(" ")

                name = line_splitted[0]
                field_type = line_splitted[1]
                description = " ".join(line_splitted[2:])
                self.fields.append(EntityField(self.name, name, field_type, description))

    def c_struct_string(self):
        """
        generates c description of structure
        """
        result = ""
        result += "    typedef struct {\n"
        for field in self.fields:
            result += field.struct_field()
        result +=f"    }} {self.name};\n"
        return result

    def cpp_struct_string(self):
        """
        generates cpp description of structure
        """
        result = ""
        result += f"    struct {self.name} {{\n"
        for field in self.fields:
            result += field.struct_field()
        result +=f"    }};\n"
        return result

    def __str__(self) -> str:
        result = ""
        result += f'---@class struct_{self.name}\n'
        for field in self.fields:
            if field.value.ignore_in_data_layout:
                continue
            if field.value.c_type:
                result += f'---@field {field.name} {field.value.lsp_type} {field.description}\n'

        # struct declaration
        result += "ffi.cdef[[\n"
        result += self.c_struct_string()
        result += "]]\n"

        return result


class EntityDescription:
    """
    Description of entity fields
    """
    name: str
    max_count: int
    fields: typing.List[EntityField]
    links: typing.List[LinkField]
    is_raws: bool
    is_relationship: bool
    erasable: bool

    def generate_dcon_description(self):
        """
        Generates DataContainer compliant description
        """
        result =   "object {\n"
        result += f"    name {{ {self.name} }}\n"
        if not self.erasable:
            result += "    storage_type { contiguous }\n"
        else:
            result += "    storage_type { erasable }\n"
        result += f"    size {{ {self.max_count} }}\n"
        result += "    tag {scenario}\n"


        # for field in self.fields:
        #     if field.value.c_type:
        #         result +=  "    property{\n"
        #         result += f"        name = {{ {field.name} }}\n"
        #         result += f"        type = {{ {field.value.dcon_type} }}\n"
        #         result +=  "        tag = { scenario }\n"
        #         result +=  "    }\n"

        result += "}\n"
        return result

    def __init__(self, name, max_count, is_raw) -> None:
        self.name = name
        self.max_count = max_count
        self.fields = []
        self.links = []

        if is_raw:
            self.erasable = False
        else:
            self.erasable = True

        load_path = ""

        self.is_raws = is_raw

        print("REGISTER ID: " + prefix_to_id_name(self.name))
        REGISTERED_ID_NAMES[prefix_to_id_name(self.name)] = True
        REGISTERED_NAMES[self.name] = self

        if not is_raw:
            ENTITY_LIST.append(self)
            load_path = DESCRIPTION_PATH
        else:
            RAWS_LIST.append(self)
            load_path = DESCRIPTION_RAWS_PATH

        self.is_relationship = False

        with open(f"{load_path}/{name}.txt", "r", encoding="utf8") as file:
            for line in file.readlines():
                line_splitted = line.strip().split(" ")

                if line_splitted[0] == "link":
                    name = line_splitted[2]
                    field_type = line_splitted[3]
                    description = " ".join(line_splitted[4:])
                    field = LinkField(self.name, name, field_type, description)
                    if line_splitted[1] == "many":
                        field.can_repeat = True
                    else:
                        field.can_repeat = False

                    print("REGISTER LINK:", field_type, self.name)
                    if field_type in REGISTERED_LINKS:
                        REGISTERED_LINKS[field_type].append((self.name, name))
                    else:
                        REGISTERED_LINKS[field_type] = [(self.name, name)]
                    self.links.append(field)
                    self.is_relationship = True
                else:
                    name = line_splitted[0]
                    field_type = line_splitted[1]

                    array_size = 1
                    array_index = "uint32_t"

                    if field_type.endswith(']'):
                        field_type = line_splitted[1].split('[')[0]
                        raw_array_size = (line_splitted[1].split('[')[1]).rstrip("]")
                        if raw_array_size.isnumeric():
                            array_size = int(raw_array_size)
                        else:
                            if raw_array_size in REGISTERED_ENUMS:
                                array_size = REGISTERED_ENUMS[raw_array_size].max_count
                                array_index = raw_array_size
                            elif raw_array_size in REGISTERED_NAMES:
                                array_size = REGISTERED_NAMES[raw_array_size].max_count
                                array_index = raw_array_size
                            else:
                                raise RuntimeError(f"INVALID PROPERTY {name} IN {self.name}")


                    description = " ".join(line_splitted[2:])

                    self.fields.append(EntityField(self.name, name, field_type, description, array_size, array_index))

    def for_each(self) -> str:
        """
        generates for each iterator for given item
        """
        result = ""
        result += f"---@param func fun(item: {prefix_to_id_name(self.name)}) \n"
        result += f"function {NAMESPACE}.for_each_{self.name}(func)\n"
        result += f"    for _, item in pairs({NAMESPACE}.{self.name}_indices_set) do\n"
        result +=  "        func(item)\n"
        result +=  "    end\n"
        result +=  "end\n"
        result += f"---@param func fun(item: {prefix_to_id_name(self.name)}):boolean \n"
        result += f"---@return table<{prefix_to_id_name(self.name)}, {prefix_to_id_name(self.name)}> \n"
        result += f"function {NAMESPACE}.filter_{self.name}(func)\n"
        result += f"    ---@type table<{prefix_to_id_name(self.name)}, {prefix_to_id_name(self.name)}> \n"
        result +=  "    local t = {}\n"
        result += f"    for _, item in pairs({NAMESPACE}.{self.name}_indices_set) do\n"
        result +=  "        if func(item) then t[item] = item end\n"
        result +=  "    end\n"
        result +=  "    return t\n"
        result +=  "end\n"
        return result


    def delete_string(self) -> str:
        """
        Generates function responsible for deletion of an object
        """
        result = ""
        result += f"function {NAMESPACE}.delete_{self.name}(i)\n"
        if self.is_relationship:
            for field in self.links:
                if field.can_repeat:
                    result += f"    do\n"
                    result += f"        local old_value = {NAMESPACE}.{self.name}[i].{field.name}\n"
                    result += f"        {field.remove_key_func_name()}(i, old_value)\n"
                    result += f"    end\n"
                else:
                    result += f"    do\n"
                    result += f"        local old_value = {NAMESPACE}.{self.name}[i].{field.name}\n"
                    result += f"        {field.remove_key_func_name()}(old_value)\n"
                    result += f"    end\n"
        else:
            if self.name in REGISTERED_LINKS:
                for relation in REGISTERED_LINKS[self.name]:
                    link = REGISTERED_NAMES[relation[0]]
                    field_name = relation[1]
                    is_unique = True
                    target_field = None
                    for field in link.links:
                        if field.name == field_name:
                            # print(relation, field.can_repeat)
                            if field.can_repeat:
                                is_unique = False
                            target_field = field
                    if target_field is None:
                        raise RuntimeError(f"link {self.name} {relation} was not found")
                    result += f"    do\n"
                    # print(self.name, relation, is_unique)
                    if is_unique:
                        result += f"        local to_delete = {target_field.get_from_function()}(i)\n"
                        result += f"        if to_delete ~= INVALID_ID then\n"
                        result += f"            {NAMESPACE}.delete_{link.name}(to_delete)\n"
                        result += f"        end\n"
                    else:
                        result += f"        ---@type {prefix_to_id_name(link.name)}[]\n"
                        result += f"        local to_delete = {{}}\n"
                        result += f"        if {target_field.get_from_function()}(i) ~= nil then\n"
                        result += f"            for _, value in ipairs({target_field.get_from_function()}(i)) do\n"
                        result +=  "                table.insert(to_delete, value)\n"
                        result += f"            end\n"
                        result += f"        end\n"
                        result += f"        for _, value in ipairs(to_delete) do\n"
                        result += f"            {NAMESPACE}.delete_{link.name}(value)\n"
                        result += f"        end\n"
                    result += f"    end\n"
        # result += f"    {self.name}_indices_pool[i] = true\n"
        result += f"    {NAMESPACE}.{self.name}_indices_set[i] = nil\n"
        result += f"    return DCON.dcon_delete_{self.name}(i - 1)\n"
        result +=  "end\n"
        return result


    def __str__(self) -> str:
        result = f"----------{self.name}----------\n\n"

        result += f"\n---{self.name}: LSP types---\n"
        #id
        result += f"\n---Unique identificator for {self.name} entity\n"
        result += f'---@alias {prefix_to_id_name(self.name)} number\n\n'

        #fat id
        result += f'---@class (exact) fat_{prefix_to_id_name(self.name)}\n'
        result += f'---@field id {prefix_to_id_name(self.name)} Unique {self.name} id\n'
        for field in self.fields:
            if field.array_size == 1 and not field.value.ignore_in_data_layout:
                result += f'---@field {field.name} {field.value.lsp_type} {field.description}\n'
        for field in self.links:
            result += f'---@field {field.name} {field.value.lsp_type} {field.description}\n'

        result += "\n"

        # struct:
        result += f'---@class struct_{self.name}\n'
        for field in self.fields:
            if field.value.ignore_in_data_layout:
                continue
            if field.value.c_type:
                if field.array_size == 1 and not field.value.ignore_in_data_layout:
                    result += f'---@field {field.name} {field.value.lsp_type} {field.description}\n'
                else:
                    result += f'---@field {field.name} table<{field.index.lsp_type}, {field.value.lsp_type}> {field.description}\n'
        for field in self.links:
            if field.value.c_type:
                result += f'---@field {field.name} {field.value.lsp_type} {field.description}\n'

        result += "\n"

        #raw data
        if self.is_raws:
            # result += f'---@class {prefix_to_id_name(self.name)}_data_blob\n'
            # for field in self.fields:
            #     if field.
            #     result += f'---@field {field.name} {field.value.lsp_type} {field.description}\n'
            # for field in self.links:
            #     result += f'---@field {field.name} {field.value.lsp_type} {field.description}\n'

            #data for entity setup

            result += f'---@class (exact) {prefix_to_id_name(self.name)}_data_blob_definition\n'
            for field in self.fields:
                if field.value.generated_during_runtime:
                    continue
                if field.value.default_value is None:
                    if field.array_size == 1:
                        result += f'---@field {field.name} {field.value.lsp_type} {field.description}\n'
                    else:
                        if not field.value.c_type in REGISTERED_STRUCTS:
                            result += f'---@field {field.name} {field.value.lsp_type}[] {field.description}\n'
                else:
                    result += f'---@field {field.name} {field.value.lsp_type}? {field.description}\n'

            for field in self.links:
                result += f'---@field {field.name} {field.value.lsp_type} {field.description}\n'

            # setup function to avoid loops over all key-value pairs
            result += f"---Sets values of {self.name} for given id\n"
            result += f"---@param id {prefix_to_id_name(self.name)}\n"
            result += f"---@param data {prefix_to_id_name(self.name)}_data_blob_definition\n"
            result += f"function {NAMESPACE}.setup_{self.name}(id, data)\n"
            for field in self.fields:
                if not field.value.default_value is None:
                    result += f"    {field.setter_name()}(id, {field.value.default_value})\n"
            for field in self.fields:
                if field.value.generated_during_runtime:
                    continue
                if field.value.ignore_in_data_layout:
                    continue
                if field.value.default_value is None:
                    if field.array_size == 1:
                        result += f"    {field.setter_name()}(id, data.{field.name})\n"
                    else:
                        if field.value.c_type in REGISTERED_STRUCTS:
                            #print(field.value.c_type)
                            pass
                        else:
                            if field.index.lsp_type in REGISTERED_ENUMS:
                                result += f"    for i, value in ipairs(data.{field.name}) do\n"
                                result += f"        {field.setter_name()}(id, i, value)\n"
                                result += f"    end\n"
                            else:
                                result += f"    for i, value in ipairs(data.{field.name}) do\n"
                                result += f"        {field.setter_name()}(id, i - 1, value)\n"
                                result += f"    end\n"
                else:
                    result += f"    if data.{field.name} ~= nil then\n"
                    result += f"        {field.setter_name()}(id, data.{field.name})\n"
                    result += f"    end\n"
            result += f"end\n"




        result += "\n"

        # struct declaration
        result += "ffi.cdef[[\n"
        result += "    typedef struct {\n"
        for field in self.fields:
            result += field.struct_field()
        for field in self.links:
            result += field.struct_field()
        result += f"    }} {self.name};\n"
        # declare dcon functions:
        if self.erasable:
            result += f"void dcon_delete_{self.name}(int32_t j);\n"
        result += f"int32_t dcon_create_{self.name}();\n"
        result += f"void dcon_{self.name}_resize(uint32_t sz);\n"
        result += "]]\n"

        # arrays
        result += f"\n---{self.name}: FFI arrays---\n"

        for field in self.fields:
            if field.value.ignore_in_data_layout:
                continue
            if not field.value.c_type:
                result += field.array_string(self.max_count)


        # DCON
        # result += f"DCON.dcon_{self.name}_resize({self.max_count - 2})\n"
        # AOS
        result +=  "---@type nil\n"
        result += f"{NAMESPACE}.{self.name}_calloc = ffi.C.calloc(1, ffi.sizeof(\"{self.name}\") * {self.max_count + 1})\n"
        result += f"---@type table<{prefix_to_id_name(self.name)}, struct_{self.name}>\n"
        result += f"{NAMESPACE}.{self.name} = ffi.cast(\"{self.name}*\", {NAMESPACE}.{self.name}_calloc)\n"

        for field in self.links:
            result += field.array_string(self.max_count)
            result += field.accessor_string()
            if field.can_repeat:
                result +=   f"for i = 1, {self.max_count} do\n"\
                            f"    {field.local_accessor_name()}[i] = {{}}\n"\
                            f"end\n"\

        result += f"\n---{self.name}: LUA bindings---\n\n"

        # indices handling:

        result += f"{NAMESPACE}.{self.name}_size = {self.max_count}\n"

        result += f"---@type table<{prefix_to_id_name(self.name)}, boolean>\n"
        result += f"local {self.name}_indices_pool = ffi.new(\"bool[?]\", {self.max_count})\n"
        result += f"for i = 1, {self.max_count - 1} do\n    {self.name}_indices_pool[i] = true \nend\n"

        result += f"---@type table<{prefix_to_id_name(self.name)}, {prefix_to_id_name(self.name)}>\n"
        result += f"{NAMESPACE}.{self.name}_indices_set = {{}}\n"

        result += f"function {NAMESPACE}.create_{self.name}()\n"
        result += f"    ---@type number\n"
        result += f"    local i = DCON.dcon_create_{self.name}() + 1\n"
        # result += f"    for i = 1, {self.max_count - 1} do\n"
        # result += f"        if {self.name}_indices_pool[i] then\n"
        # result += f"            {self.name}_indices_pool[i] = false\n"
        result += f"            {NAMESPACE}.{self.name}_indices_set[i] = i\n"
        # for field in self.fields:
        #     if not field.value.default_value is None and not field.value.ignore_in_data_layout:
        #         result += f"            {field.setter_name()}(i, {field.value.default_value})\n"
        # result +=  "            return i\n"
        # result +=  "        end\n"
        # result +=  "    end\n"
        # result += f"    error(\"Run out of space for {self.name}\")\n"
        result += f"    return i\n"
        result +=  "end\n"

        if self.erasable:
            result += self.delete_string()

        result += self.for_each()

        result += "\n"

        #bindings lua
        for field in self.fields:
            result += field.lua_bindings()
        for field in self.links:
            result += field.lua_bindings()

        result += "\n"

        if self.is_relationship:
            pass
            # table for relationship


            # result += "---@type "
            # for item in self.links:
            #     result += f"table<{item.value.lsp_type}, "
            # result += f"{prefix_to_id_name(self.name)}"
            # for item in self.links:
            #     result += ">"
            # result += f"\n{NAMESPACE}.relation_{self.name} = {{}}\n"


            # # getter for relationship:
            # result += f"function {NAMESPACE}.get_{self.name}("
            # for item in self.links[:-1]:
            #     result += f"{item.name}, "
            # result += f"{self.links[-1].name})\n"
            # scope = f"{NAMESPACE}.relation_{self.name}"
            # for item in self.links:
            #     result += f"    if {scope}[{item.name}] == nil then return 0 end\n"
            #     scope = scope + f"[{item.name}]"
            # result += f"    return {scope}\n"
            # result += "end\n"

            # # setter for relationship
            # result += f"function {NAMESPACE}.set_{self.name}("
            # for item in self.links[:-1]:
            #     result += f"{item.name}, "
            # result += f"{self.links[-1].name})\n"
            # scope = f"{NAMESPACE}.relation_{self.name}"
            # for item in self.links[:-1]:
            #     result += f"    if {scope}[{item.name}] == nil then {scope}[{item.name}] = {{}} end\n"
            #     scope = scope + f"[{item.name}]"
            # result += f"    if {scope}[{self.links[-1].name}] ~= nil then error(\"ATTEMPT TO CREATE ALREADY EXISTING RELATIONSHIP\") end\n"
            # result += f"    local new_id = {NAMESPACE}.create_{self.name}()\n"
            # result += f"    {scope}[{self.links[-1].name}] = new_id\n"
            # for item in self.links:
            #     result += f"    {item.setter_name()}(new_id, {item.name})\n"
            #     if item.can_repeat:
            #         result += f"    if {item.local_accessor_name()}[{item.name}] == nil then {item.local_accessor_name()}[{item.name}] = {{}} end\n"
            #         result += f"    table.insert({item.local_accessor_name()}[{item.name}], new_id)\n"
            #     else:
            #         result += f"    {item.local_accessor_name()}[{item.name}] = new_id\n"
            # result +=  "    return new_id\n"
            # result += "end\n"


        result += "\n"
        #metatable

        result += f"local fat_{prefix_to_id_name(self.name)}_metatable = {{\n"

        result += "    __index = function (t,k)\n"
        for field in self.fields:
            if field.value.ignore_in_data_layout:
                continue
            if field.array_size == 1:
                result += f"        if (k == \"{field.name}\") then return {field.getter_name()}(t.id) end\n"
        for field in self.links:
            result += f"        if (k == \"{field.name}\") then return {field.getter_name()}(t.id) end\n"
        result += "        return rawget(t, k)\n"
        result += "    end,\n"

        result += "    __newindex = function (t,k,v)\n"
        for field in self.fields:
            if field.value.ignore_in_data_layout:
                continue
            if field.array_size == 1:
                result += f"        if (k == \"{field.name}\") then\n"
                result += f"            {field.setter_name()}(t.id, v)\n"
                result +=  "            return\n"
                result +=  "        end\n"
        for field in self.links:
            result += f"        if (k == \"{field.name}\") then\n"
            result += f"            {field.setter_name()}(t.id, v)\n"
            result +=  "            return\n"
            result +=  "        end\n"
        result += "        rawset(t, k, v)\n"
        result += "    end\n"

        result += "}\n"

        #fat id
        result += f'---@param id {prefix_to_id_name(self.name)}\n'
        result += f'---@return fat_{prefix_to_id_name(self.name)} fat_id\n'
        result += f"function {NAMESPACE}.fatten_{self.name}(id)\n"
        result +=  "    local result = {id = id}\n"
        result += f"    setmetatable(result, fat_{prefix_to_id_name(self.name)}_metatable)"
        result +=  "    return result\n"
        result +=  "end\n"
        return result


class StaticEntityDescription(EntityDescription):
    """
    Description of static entities:
    data is generated from the table during code gen stage and "hardcoded" into the game
    """

    data: typing.List[typing.List[str]]

    def __init__(self, name) -> None:
        super().__init__(name, 0, True)
        self.max_count = 2

        REGISTERED_ENUMS[self.name.upper()] = self

        # create columns:
        self.data = []

        # open file and read columns
        with open(f"{DESCRIPTION_STATIC_PATH}/{name}.csv", "r", encoding="utf8") as raw_table:
            raw_table.readline() # we describe data in column headers
            for line in raw_table.readlines():
                splitted_line = line.strip().split(";")
                self.data.append(splitted_line)
                self.max_count += 1

    def __str__(self) -> str:
        result = super().__str__()
        # generate enum:
        result += f"---@enum {self.name.upper()}\n"
        result += f"{self.name.upper()} = {{\n"
        i = 0
        result += f"    INVALID = {i},\n"
        for row in self.data:
            i += 1
            result += f"    {row[0].upper()} = {i},\n"
        result += "}\n"

        # fill with data
        result += f"local index_{self.name}\n"
        for row in self.data:
            result += f"index_{self.name} = {NAMESPACE}.create_{self.name}()\n"
            for header, data in zip(self.fields, row):
                if header.value.c_type:
                    result += f"{header.setter_name()}(index_{self.name}, {data})\n"
                elif header.value.lsp_type == "string":
                    result += f"{header.setter_name()}(index_{self.name}, \"{data}\")\n"
                else:
                    result += f"{header.setter_name()}(index_{self.name}, {data})\n"

        return result


ENTITY_LIST: typing.List[EntityDescription] = []
RAWS_LIST: typing.List[EntityDescription] = []
STATIC_LIST: typing.List[StaticEntityDescription] = []
STRUCTS_LIST: typing.List[StructDescription] = []

def auxiliary_types():
    """
    Generates helper types for lsp
    """

    result = "\n"

    # result += "---@class LuaDataBlob\n"
    # for entity in ENTITY_LIST:
    #     for field in entity.fields:
    #         if not field.is_ctype:
    #             result += f"---@field {field.array_name()} ({field.lsp_type})[]\n"

    result += "\n"

    return result




def save_state():
    """
    Generates routine which saves state in two files:\n
    One for c arrays -- fast\n
    And another one for lua tables -- slow
    """
    result = f"function {NAMESPACE}.save_state()\n"
    # result += "    local current_lua_state = {}\n"

    # for entity in ENTITY_LIST:
    #     for field in entity.fields:
    #         if not field.is_ctype:
    #             result += f"    current_lua_state.{field.array_name()} = {field.local_var_name()}\n"

    # result += f"\n    bitser.dumpLoveFile(\"{SAVE_FILE_NAME_LUA}\", current_lua_state)\n\n"

    result += "    local current_offset = 0\n"
    result += "    local current_shift = 0\n"
    result += "    local total_ffi_size = 0\n"


    for entity in ENTITY_LIST:
        result += f'    total_ffi_size = total_ffi_size + ffi.sizeof("{entity.name}") * {entity.max_count}\n'

    result += "    local current_buffer = ffi.new(\"uint8_t[?]\", total_ffi_size)\n"

    for entity in ENTITY_LIST:
        result +=   f'    current_shift = ffi.sizeof("{entity.name}") * {entity.max_count}\n'
        result +=   f'    ffi.copy(current_buffer + current_offset,' \
                            f" {NAMESPACE}.{entity.name}, current_shift)\n"
        result +=    "    current_offset = current_offset + current_shift\n"

    # for entity in ENTITY_LIST:
    #     for field in entity.fields:
    #         if field.is_ctype:
    #             result += f'    total_ffi_size = total_ffi_size + ffi.sizeof("{field.type}") * {entity.max_count}\n'


    # for entity in ENTITY_LIST:
    #     for field in entity.fields:
    #         if field.is_ctype:
    #             result += f'    current_shift = ffi.sizeof("{field.type}") * {entity.max_count}\n'
    #             result +=   f'    ffi.copy(current_buffer + current_offset,' \
    #                         f" {field.local_var_name()}, current_shift)\n"
    #             result += "    current_offset = current_offset + current_shift\n"

    result += f"    assert(love.filesystem.write(\"{SAVE_FILE_NAME_FFI}\", ffi.string(current_buffer, total_ffi_size)))\n"

    result += "end\n"
    return result

def load_state():
    """
    Generates routine which saves state in two files:\n
    One for c arrays -- fast\n
    And another one for lua tables -- slow
    """
    result = f"function {NAMESPACE}.load_state()\n"
    # result += "    ---@type LuaDataBlob|nil\n"
    # result += f"    local loaded_lua_state = bitser.loadLoveFile(\"{SAVE_FILE_NAME_LUA}\")\n"
    # result += "    assert(loaded_lua_state)\n"

    # for entity in ENTITY_LIST:
    #     for field in entity.fields:
    #         if not field.is_ctype:
    #             result += f"    for key, value in pairs(loaded_lua_state.{field.array_name()}) do\n"
    #             result += f"        {field.local_var_name()}[key] = value\n"
    #             result += "    end\n"

    result +=f"    local data_love, error = love.filesystem.newFileData(\"{SAVE_FILE_NAME_FFI}\")\n"
    result += "    assert(data_love, error)\n"
    result += "    local data = ffi.cast(\"uint8_t*\", data_love:getPointer())\n"
    result += "    local current_offset = 0\n"
    result += "    local current_shift = 0\n"
    result += "    local total_ffi_size = 0\n"

    for entity in ENTITY_LIST:
        result += f'    total_ffi_size = total_ffi_size + ffi.sizeof("{entity.name}") * {entity.max_count}\n'

    for entity in ENTITY_LIST:
        result += f'    current_shift = ffi.sizeof("{entity.name}") * {entity.max_count}\n'
        result += f'    ffi.copy({NAMESPACE}.{entity.name},' \
                    " data + current_offset, current_shift)\n"
        result +=  "    current_offset = current_offset + current_shift\n"

    # for entity in ENTITY_LIST:
    #     for field in entity.fields:
    #         if field.is_ctype:
    #             result += f'    total_ffi_size = total_ffi_size + ffi.sizeof("{field.type}") * {entity.max_count}\n'

    # # result += "    local current_buffer = ffi.new(\"uint8_t[?]\", total_ffi_size)\n"

    # for entity in ENTITY_LIST:
    #     for field in entity.fields:
    #         if field.is_ctype:
    #             result += f'    current_shift = ffi.sizeof("{field.type}") * {entity.max_count}\n'
    #             result +=   f'    ffi.copy({field.local_var_name()},' \
    #                         " data + current_offset, current_shift)\n"
    #             result += "    current_offset = current_offset + current_shift\n"

    result += "end\n"
    return result


def tests():
    """
    Generates tests for generated code
    """
    result = ""
    for i in range(3):
        result += f"function {NAMESPACE}.test_save_load_{i}()\n"

        # generate data
        random.seed(i)
        for entity in ENTITY_LIST:
            for field in entity.fields:
                if field.value.c_type:
                    result += f"    print(\"{entity.name} {field.name}\")\n"
                    result += f"    for i = 0, {entity.max_count} do\n"
                    if field.value.c_type in REGISTERED_STRUCTS:
                        if field.array_size == 1:
                            for secondary_field in REGISTERED_STRUCTS[field.value.c_type].fields:
                                generated_value = secondary_field.value.generate_value()
                                result += f"        {NAMESPACE}.{entity.name}[i].{field.name}.{secondary_field.name} = {generated_value}\n"
                        else:
                            for secondary_field in REGISTERED_STRUCTS[field.value.c_type].fields:
                                generated_value = secondary_field.value.generate_value()
                                result += f"    for j = 0, {field.array_size - 1} do\n"
                                result += f"        {NAMESPACE}.{entity.name}[i].{field.name}[j].{secondary_field.name} = {generated_value}\n"
                                result +=  "    end\n"
                    else:
                        if field.array_size == 1:
                            result += f"        {NAMESPACE}.{entity.name}[i].{field.name} = {field.value.generate_value()}\n"
                        else:
                            result += f"    for j = 0, {field.array_size - 1} do\n"
                            result += f"        {NAMESPACE}.{entity.name}[i].{field.name}[j] = {field.value.generate_value()}\n"
                            result +=  "    end\n"
                    result +=  "    end\n"

        # checks
        result += f"    {NAMESPACE}.save_state()\n"
        result += f"    {NAMESPACE}.load_state()\n"

        result +=  "    local test_passed = true\n"

        random.seed(i)
        for entity in ENTITY_LIST:
            for field in entity.fields:
                if field.value.c_type:
                    result += f"    for i = 0, {entity.max_count} do\n"
                    if field.value.c_type in REGISTERED_STRUCTS:
                        if field.array_size == 1:
                            for secondary_field in REGISTERED_STRUCTS[field.value.c_type].fields:
                                generated_value = secondary_field.value.generate_value()
                                result += f"        test_passed = test_passed and {NAMESPACE}.{entity.name}[i].{field.name}.{secondary_field.name} == {generated_value}\n"
                        else:
                            for secondary_field in REGISTERED_STRUCTS[field.value.c_type].fields:
                                generated_value = secondary_field.value.generate_value()
                                result += f"    for j = 0, {field.array_size - 1} do\n"
                                result += f"        test_passed = test_passed and {NAMESPACE}.{entity.name}[i].{field.name}[j].{secondary_field.name} == {generated_value}\n"
                                result +=  "    end\n"
                    else:
                        if field.array_size == 1:
                            result += f"        test_passed = test_passed and {NAMESPACE}.{entity.name}[i].{field.name} == {field.value.generate_value()}\n"
                        else:
                            result += f"    for j = 0, {field.array_size - 1} do\n"
                            result += f"        test_passed = test_passed and {NAMESPACE}.{entity.name}[i].{field.name}[j] == {field.value.generate_value()}\n"
                            result +=  "    end\n"
                    result +=  "    end\n"

        result += f"    print(\"SAVE_LOAD_TEST_{i}:\")\n"
        result +=  "    if test_passed then print(\"PASSED\") else print(\"ERROR\") end\n"
        result += "end\n"

        result += f"function {NAMESPACE}.test_set_get_{i}()\n"


        for entity in ENTITY_LIST:
            result += f"    local id = {NAMESPACE}.create_{entity.name}()\n"
            result += f"    local fat_id = {NAMESPACE}.fatten_{entity.name}(id)\n"
            random.seed(i)
            for field in entity.fields:
                if field.value.c_type:
                    if field.value.c_type in REGISTERED_STRUCTS:
                        if field.array_size == 1:
                            for secondary_field in REGISTERED_STRUCTS[field.value.c_type].fields:
                                generated_value = secondary_field.value.generate_value()
                                result += f"    {NAMESPACE}.{entity.name}[id].{field.name}.{secondary_field.name} = {generated_value}\n"
                        else:
                            for secondary_field in REGISTERED_STRUCTS[field.value.c_type].fields:
                                generated_value = secondary_field.value.generate_value()
                                result += f"    for j = 0, {field.array_size - 1} do\n"
                                result += f"        {NAMESPACE}.{entity.name}[id].{field.name}[j].{secondary_field.name} = {generated_value}\n"
                                result +=  "    end\n"
                    else:
                        if field.array_size == 1:
                            result += f"    fat_id.{field.name} = {field.value.generate_value()}\n"
                        else:
                            result += f"    for j = 0, {field.array_size - 1} do\n"
                            result += f"        {NAMESPACE}.{entity.name}[id].{field.name}[j] = {field.value.generate_value()}\n"
                            result +=  "    end\n"
            result += "    local test_passed = true\n"
            random.seed(i)
            for field in entity.fields:
                if field.value.c_type:
                    if field.value.c_type in REGISTERED_STRUCTS:
                        if field.array_size == 1:
                            for secondary_field in REGISTERED_STRUCTS[field.value.c_type].fields:
                                generated_value = secondary_field.value.generate_value()
                                result += f"    test_passed = test_passed and {NAMESPACE}.{entity.name}[id].{field.name}.{secondary_field.name} == {generated_value}\n"
                                result += f"    if not test_passed then print(\"{field.name}.{secondary_field.name}\", {generated_value}, {NAMESPACE}.{entity.name}[id].{field.name}[0].{secondary_field.name}) end\n"
                        else:
                            for secondary_field in REGISTERED_STRUCTS[field.value.c_type].fields:
                                generated_value = secondary_field.value.generate_value()
                                result += f"    for j = 0, {field.array_size - 1} do\n"
                                result += f"        test_passed = test_passed and {NAMESPACE}.{entity.name}[id].{field.name}[j].{secondary_field.name} == {generated_value}\n"
                                result +=  "    end\n"
                                result += f"    if not test_passed then print(\"{field.name}.{secondary_field.name}\", {generated_value}, {NAMESPACE}.{entity.name}[id].{field.name}[0].{secondary_field.name}) end\n"
                    else:
                        if field.array_size == 1:
                            generated_value = field.value.generate_value()
                            result += f"    test_passed = test_passed and fat_id.{field.name} == {generated_value}\n"
                            result += f"    if not test_passed then print(\"{field.name}\", {generated_value}, fat_id.{field.name}) end\n"
                        else:
                            generated_value = field.value.generate_value()
                            result += f"    for j = 0, {field.array_size - 1} do\n"
                            result += f"        test_passed = test_passed and {NAMESPACE}.{entity.name}[id].{field.name}[j] == {generated_value}\n"
                            result +=  "    end\n"
                            result += f"    if not test_passed then print(\"{field.name}\", {generated_value}, {NAMESPACE}.{entity.name}[id].{field.name}[0]) end\n"

            result += f"    print(\"SET_GET_TEST_{i}_{entity.name}:\")\n"
            result +=  "    if test_passed then print(\"PASSED\") else print(\"ERROR\") end\n"
        result += "end\n"

    return result

Jobtype = StaticEntityDescription("jobtype")
Need = StaticEntityDescription("need")
Rank = StaticEntityDescription("character_rank")
Trait = StaticEntityDescription("trait")
TradeGoodCategory = StaticEntityDescription("trade_good_category")
WarbandStatus = StaticEntityDescription("warband_status")
WarbandStance = StaticEntityDescription("warband_stance")
BuildingArchetype = StaticEntityDescription("building_archetype")
ForageResource = StaticEntityDescription("forage_resource")
BudgetCategory = StaticEntityDescription("budget_category")
EconomyReason = StaticEntityDescription("economy_reason")

TILES_MAX_COUNT = 500 * 500 * 6

BudgetCategoryData = StructDescription("budget_per_category_data")

TradeGoodDescription = EntityDescription("trade_good", 100, True)
UseCaseDescription = EntityDescription("use_case", 100, True)
GoodContainer = StructDescription("trade_good_container")
UseContainer = StructDescription("use_case_container")
UseWeight = EntityDescription("use_weight", 300, True)
Biome = EntityDescription("biome", 100, True)
Bedrock = EntityDescription("bedrock", 150, True)
Resource = EntityDescription("resource", 300, True)
ForageContainer = StructDescription("forage_container")

TileDescription = EntityDescription("tile", TILES_MAX_COUNT, False)
TileDescription.erasable = False
ResourcesLocation = StructDescription("resource_location")

UnitType = EntityDescription("unit_type", 20, True)

Satisfaction = StructDescription("need_satisfaction")
NeedDefinition = StructDescription("need_definition")

Job = EntityDescription("job", 250, True)

JobContainer = StructDescription("job_container")

ProductionMethod = EntityDescription("production_method", 250, True)
Technology = EntityDescription("technology", 400, True)
TechnologyUnlock = EntityDescription("technology_unlock", 800, True)

BuildingType = EntityDescription("building_type", 250, True)
TechnologyBuilding = EntityDescription("technology_building", 400, True)
TechnologyUnit = EntityDescription("technology_unit", 400, True)

Race = EntityDescription("race", 15, True)

POPS_MAX_COUNT = 300000
REALMS_MAX_COUNT = 15000

Pop = EntityDescription("pop", POPS_MAX_COUNT, False)
Province = EntityDescription("province", 20000, False)
Army = EntityDescription("army", 5000, False)
Warband = EntityDescription("warband", 20000, False)
Realm = EntityDescription("realm", REALMS_MAX_COUNT, False)

Negotiations = EntityDescription("negotiation", 2500, False)

Building = EntityDescription("building", 200000, False)
BuildingOwnership = EntityDescription("ownership", 200000, False)
Employment = EntityDescription("employment", 300000, False)
BuildingLocation = EntityDescription("building_location", 200000, False)

ArmyMembership = EntityDescription("army_membership", 10000, False)
WarbandLeader = EntityDescription("warband_leader", 10000, False)
WarbandRecruiter = EntityDescription("warband_recruiter", 10000, False)
WarbandCommander = EntityDescription("warband_commander", 10000, False)
WarbandLocation = EntityDescription("warband_location", 10000, False)
WarbandUnit = EntityDescription("warband_unit", 50000, False)

CharacterLocation = EntityDescription("character_location", 100000, False)
HomeLocation = EntityDescription("home", POPS_MAX_COUNT, False)
PopLocation = EntityDescription("pop_location", POPS_MAX_COUNT, False)
OutlawLocation = EntityDescription("outlaw_location", POPS_MAX_COUNT, False)

TileMembership = EntityDescription("tile_province_membership", TILES_MAX_COUNT, False)
ProvinceNeighbourhood = EntityDescription("province_neighborhood", 250000, False)

ParentChild = EntityDescription("parent_child_relation", 900000, False)
Loyalty = EntityDescription("loyalty", 10000, False)
Succession = EntityDescription("succession", 10000, False)

RealmArmies = EntityDescription("realm_armies", REALMS_MAX_COUNT, False)
RealmGuard = EntityDescription("realm_guard", REALMS_MAX_COUNT, False)
RealmOverseer = EntityDescription("realm_overseer", REALMS_MAX_COUNT, False)
RealmLeader = EntityDescription("realm_leadership", REALMS_MAX_COUNT, False)
RealmSubjects = EntityDescription("realm_subject_relation", REALMS_MAX_COUNT, False)
RealmTaxCollector = EntityDescription("tax_collector", REALMS_MAX_COUNT * 3, False)
RealmPersonalRights = EntityDescription("personal_rights", REALMS_MAX_COUNT * 30, False)
RealmProvince = EntityDescription("realm_provinces", REALMS_MAX_COUNT * 2, False)
RealmPopularity = EntityDescription("popularity", REALMS_MAX_COUNT * 30, False)

with open(OUTPUT_PATH, "w", encoding="utf8") as out:
    out.write('local ffi = require("ffi")\n')
    out.write(  'ffi.cdef[[\n'\
                '    void* calloc( size_t num, size_t size );\n'\
                ']]\n'
    )
    out.write('local bitser = require("engine.bitser")\n')
    out.write("\n")
    out.write(f'{NAMESPACE} = {{}}\n')
    for struct_description in STRUCTS_LIST:
        out.write(str(struct_description))

    for entity_description in ENTITY_LIST:
        out.write(str(entity_description))
    for entity_description in RAWS_LIST:
        out.write(str(entity_description))

    out.write(auxiliary_types())
    out.write(save_state())
    out.write(load_state())
    out.write(tests())

    out.write(f'return {NAMESPACE}\n')


with open(DCON_DESC_PATH, "w", encoding="utf8") as out:
    for entity_description in ENTITY_LIST:
        out.write(entity_description.generate_dcon_description())
    for entity_description in RAWS_LIST:
        out.write(entity_description.generate_dcon_description())

with open(CPP_COMMON_TYPES_PATH, "w", encoding="utf8") as out:
    out.write("namespace base_types {\n")
    for struct in STRUCTS_LIST:
        out.write(struct.cpp_struct_string())
        out.write("\n")
    out.write("}")
