#include <WinAPISys.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(BitOR($MB_ICONERROR, $MB_SYSTEMMODAL), 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Local $hForm = GUICreate('Test ' & StringReplace(@ScriptName, '.au3', '()'), 200, 200)
Local $Button = GUICtrlCreateButton('', 73, 62, 54, 54, $BS_ICON)
GUICtrlSetImage(-1, @SystemDir & '\shell32.dll', 45)
GUICtrlSetTip(-1, 'Log off ' & @UserName)
Local $Check = GUICtrlCreateCheckbox('Block Windows shutdown', 10, 173, 144, 21)
GUIRegisterMsg($WM_QUERYENDSESSION, 'WM_QUERYENDSESSION')
GUISetState()

; Set the highest shutdown priority for the current process to prevent closure the other processes.
_WinAPI_SetProcessShutdownParameters(0x03FF)

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Button
			Shutdown(0)
		Case $Check
			If GUICtrlRead($Check) = $GUI_CHECKED Then
				_WinAPI_ShutdownBlockReasonCreate($hForm, 'This application is blocking system shutdown because the saving critical data is in progress.')
			Else
				_WinAPI_ShutdownBlockReasonDestroy($hForm)
			EndIf
	EndSwitch
WEnd

Func WM_QUERYENDSESSION($hWnd, $Msg, $wParam, $lParam)
	#forceref $Msg, $wParam, $lParam

	Switch $hWnd
		Case $hForm
			If _WinAPI_ShutdownBlockReasonQuery($hForm) Then
				Return 0
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_QUERYENDSESSION
