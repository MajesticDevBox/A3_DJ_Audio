params [["_computer", objNull, [objNull]]];

!isNull _computer &&
{isClass (configOf _computer >> "AE3_Device")} &&
{
    isClass (configOf _computer >> "AE3_USB_Interface") ||
    {_computer getVariable ["AE3_cap_hasTerminal", false]}
}
