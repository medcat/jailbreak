void CreateForwards() {
    forwardRoundStart = CreateGlobalForward("OnJailbreakRoundStart", ET_Event,
        Param_Any, Param_Cell);
    forwardPreBalance = CreateGlobalForward("OnJailbreakPreBalance", ET_Event,
        Param_Cell);
    forwardRoundEnd = CreateGlobalForward("OnJailbreakRoundEnd", ET_Event,
        Param_Cell, Param_Cell);
    /* forwardLastRequest = CreateGlobalForward("OnJailbreakLastRequest", ET_Event,
        Param_Cell, Param_String, Param_String); */
    forwardGiveFreeday = CreateGlobalForward("OnJailbreakGiveFreeday", ET_Event,
        Param_Cell, Param_Cell);
    forwardRemoveFreeday = CreateGlobalForward("OnJailbreakRemoveFreeday", ET_Event,
        Param_Cell, Param_Cell);
    forwardGiveWarden = CreateGlobalForward("OnJailbreakGiveWarden", ET_Event,
        Param_Cell, Param_Cell);
    forwardRemoveWarden = CreateGlobalForward("OnJailbreakRemoveWarden", ET_Event,
        Param_Cell, Param_Cell);
}

Action Jailbreak_TriggerRoundStart(Event event, int rType) {
    Action result;

    Call_StartForward(forwardRoundStart);
    Call_PushCell(event);
    Call_PushCell(rType);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerRoundStart forward failed!");
    return result;
}

Action Jailbreak_TriggerRoundEnd(Event event, int rType) {
    Action result;

    Call_StartForward(forwardRoundEnd);
    Call_PushCell(event);
    Call_PushCell(rType);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerRoundEnd forward failed!");
    return result;
}

Action Jailbreak_TriggerPreBalance(int rType) {
    Action result;

    Call_StartForward(forwardPreBalance);
    Call_PushCell(rType);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerPreBalance forward failed!");
    return result;
}

/* Action Jailbreak_TriggerLastRequest(int client, const char[] info, const char[] desc) {
    Action result;

    Call_StartForward(forwardLastRequest);
    Call_PushCell(client);
    Call_PushString(info);
    Call_PushString(desc);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerLastRequest forward failed!");
    return result;
} */

// result ignored on admin command
Action Jailbreak_TriggerGiveFreeday(int client, bool force) {
    Action result;

    Call_StartForward(forwardGiveFreeday);
    Call_PushCell(client);
    Call_PushCell(force);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerGiveFreeday forward failed!");
    return result;
}

// result ignored on round end, player death, or admin command
Action Jailbreak_TriggerRemoveFreeday(int client, bool force) {
    Action result;

    Call_StartForward(forwardRemoveFreeday);
    Call_PushCell(client);
    Call_PushCell(force);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerRemoveFreeday forward failed!");
    return result;
}

Action Jailbreak_TriggerGiveWarden(int client, bool force) {
    Action result;

    Call_StartForward(forwardGiveWarden);
    Call_PushCell(client);
    Call_PushCell(force);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerGiveWarden forward failed!");
    return result;
}

Action Jailbreak_TriggerRemoveWarden(int client, bool force) {
    Action result;

    Call_StartForward(forwardRemoveWarden);
    Call_PushCell(client);
    Call_PushCell(force);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerRemoveWarden forward failed!");
    return result;
}
