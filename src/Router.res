type t = 
  | Home
  | Names
  | Profile
  | ProfileView(string)
  | NotFound

let fromUrl = (url: RescriptReactRouter.url) => {
  switch url.path {
  | list{} => Home
  | list{"names"} => Names
  | list{"profile"} => Profile
  | list{name} when Js.Re.test_(Js.Re.fromString(`^@.+${Constants.sld}$`), name) => {
      let name = name
        ->String.substringToEnd(~start=1)
        ->String.split(".")
        ->Array.getUnsafe(0)
      ProfileView(name)
    }
  | _ => NotFound
  }
}

let toUrl = (route: t) => {
  switch route {
  | Home => "/"
  | Names => "/names"
  | Profile => "/profile"
  | ProfileView(name) => "/@" ++ name
  | NotFound => "/404"
  }
}
