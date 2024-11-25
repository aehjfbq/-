import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';

export function premission(atManager,context,permission_name:string){
  try {
    atManager.requestPermissionsFromUser(context, [permission_name]).then((data) => {
      console.info("data:" + JSON.stringify(data));
      //console.info("data permissions:" + data.permissions);
      //console.info("data authResults:" + data.authResults);

    }).catch((err) => {
      console.info("data:" + JSON.stringify(err));

    })
  } catch(err) {
    console.log(`catch err->${JSON.stringify(err)}`);

  }

}
