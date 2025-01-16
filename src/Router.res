type t = 
  | Home
  | Names
  | Profile
  | NotFound

let fromUrl = (url: RescriptReactRouter.url) => {
  switch url.path {
  | list{} => Home
  | list{"names"} => Names
  | list{"profile"} => Profile
  | _ => NotFound
  }
}

let toUrl = (route: t) => {
  switch route {
  | Home => "/"
  | Names => "/names"
  | Profile => "/profile"
  | NotFound => "/404"
  }
}
