import { NgModule } from '@angular/core';
import { NativeScriptRouterModule } from 'nativescript-angular/router';
import { Routes } from '@angular/router';

import { AutoGeneratedComponent } from '@src/app/auto-generated/auto-generated.component';
import { HomeComponent } from '@src/app/home/home.component.tns';

export const routes: Routes = [
  {
      path: '',
      redirectTo: '/players',
      pathMatch: 'full',
  },
  {
      path: 'auto-generated',
      component: AutoGeneratedComponent,
  },
  {
    path: 'home',
    component: HomeComponent,
  }
];

@NgModule({
  imports: [NativeScriptRouterModule.forRoot(routes)],
  exports: [NativeScriptRouterModule]
})
export class AppRoutingModule { }
