local registry = {
	stateName = "UIUpdateAssetState";
	resData = {};
	controller = "login.fsm.controller.UIUpdateAssetState";
	view = "login.mediator.view.LoginUpdateLayer";
	
	entry = false;
	enter = {{eventName="tail",stateName="UILoginTailState"}};
	pop = {{eventName="back"}}
}
registry.resData.Texture = {}

return registry