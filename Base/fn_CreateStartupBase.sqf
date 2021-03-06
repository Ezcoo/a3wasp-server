Private ["_created","_current","_dir","_i","_object","_origin","_relDir","_relPos","_skip","_template","_toplace","_toWorld"];
_side = _this select 0;
_startPosition = _this select 1;
_template = _this select 2;

_sideID = (_side) Call WFCO_FNC_GetSideID;
_origin = createVehicle ["Land_HelipadEmpty_F", _startPosition, [], 0, "NONE"];
_dir = getDir _origin;

_toplace = objNull;
_vehicleStartPositions = [];
_shallCreateBaseArea = true;
_skip = true;

if(!(isNil '_template'))then{
    for '_i' from 0 to count(_template)-1 do {
    	_current = _template select _i;
    	_object = _current select 0;
    	_relPos = _current select 1;
    	_relDir = _current select 2;
    	_skip = false;

    	if(_object isKindOf 'Warfare_HQ_base_unfolded') then {
    	    if(_shallCreateBaseArea) then {
                _logik = (_side) Call WFCO_FNC_GetSideLogic;
                _update = true;
                _areas = _logik getVariable ["wf_basearea", []];

                _grp = createGroup sideLogic;
                _logic = _grp createUnit ["Logic", _startPosition ,[],0,"NONE"];
                _logic setVariable ["DefenseTeam", createGroup [_side, true]];
                (_logic getVariable "DefenseTeam") setVariable ["wf_persistent", true];
                _logic setVariable ["weapons",missionNamespace getVariable "WF_C_BASE_DEFENSE_MAX_AI"];
                [_logic, _side,_logik,_areas] remoteExecCall ["WFCL_FNC_RequestBaseArea", _side, true];

                _toWorld = _origin modelToWorld _relPos;
                //--- HQ init.
                _hq = [missionNamespace getVariable Format["WF_%1MHQNAME", _side], [_toWorld # 0, _toWorld # 1, 5], _sideID, 0, true, false, true] Call WFCO_FNC_CreateVehicle;
                _hq setVectorUp surfaceNormal position _hq;
                _hq setDir 90;
                if(damage _hq > 0) then { _hq setDamage 0 };
                _shallCreateBaseArea = false
            };
            _skip = true
        } else {
            if(_object isKindOf 'Base_WarfareBBarracks') then {
                _toWorld = _origin modelToWorld _relPos;
                _toWorld set [2,-0.5];
                [_object, _side,_toWorld,(_dir - _relDir),0,-1] spawn WFSE_fnc_SmallSite;
                _skip = true;
            };

            if (_object isKindOf 'Base_WarfareBLightFactory') then {
                _toWorld = _origin modelToWorld _relPos;
                _toWorld set [2,-0.6];
                [_object,_side,_toWorld,(_dir - _relDir),1,-1] spawn WFSE_fnc_MediumSite;
                _skip = true;
            };

            if (_object == 'Land_JumpTarget_F') then {
                _toWorld = _origin modelToWorld _relPos;
                _vehicleStartPositions pushBack [_toWorld # 0, _toWorld # 1, 5];
                _skip = true;
            }
        };

    	if !(_skip) then {
    		_toWorld = _origin modelToWorld _relPos;
    		if !(_object isKindOf 'StaticWeapon') then {
                _toWorld set [2,0]
    		};

            _toplace = createVehicle [_object, _toWorld, [], 0, "CAN_COLLIDE"];
            _toplace setDir (_dir - _relDir);
    		_toplace setVectorUp surfaceNormal position _toplace
    	}
    }
};

//--- Starting vehicles.
{
    _vehicle = [_x, _vehicleStartPositions # _forEachIndex, _sideID, 0, false] Call WFCO_FNC_CreateVehicle;
    (_vehicle) call WFCO_FNC_ClearVehicleCargo;
} forEach (missionNamespace getVariable Format ['WF_%1STARTINGVEHICLES', _side]);


//--- spawn of additional vehicles
switch _side do{
    case west: {
        call WFCO_fnc_respawnStartVeh;
        _tVeh = WEST_StartVeh # floor(random (count WEST_StartVeh));
        _vehicle = [_tVeh,_vehicleStartPositions # ((count _vehicleStartPositions) - 1), west, 0, false] Call WFCO_FNC_CreateVehicle;
    };
    case east:{
        call WFCO_fnc_respawnStartVeh;
        _tVeh = EAST_StartVeh # floor(random (count EAST_StartVeh));
        _vehicle = [_tVeh, _vehicleStartPositions # ((count _vehicleStartPositions) - 1), east, 0, false] Call WFCO_FNC_CreateVehicle;
    };
};

deleteVehicle _origin;
