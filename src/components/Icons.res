module Search = {
  @react.component
  let make = () => {
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path 
        d="M21 21L16.5 16.5M19 11C19 15.4183 15.4183 19 11 19C6.58172 19 3 15.4183 3 11C3 6.58172 6.58172 3 11 3C15.4183 3 19 6.58172 19 11Z" 
        stroke="#999999" 
        strokeWidth="2" 
        strokeLinecap="round" 
        strokeLinejoin="round"
        />
    </svg>
  }
}

module Close = {
  @react.component
  let make = () => {
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <g clipPath="url(#clip0_3130_28275)">
        <path fillRule="evenodd" clipRule="evenodd" d="M18.5458 5.45415C17.6083 4.51691 16.0889 4.51691 15.1517 5.45415L11.9999 8.60576L8.84816 5.45415C7.91092 4.51691 6.39138 4.51691 5.45415 5.45415C4.51691 6.39138 4.51691 7.91092 5.45415 8.84829L8.60576 11.9999L5.45415 15.1517C4.51691 16.0889 4.51691 17.6083 5.45415 18.5458C6.39138 19.4829 7.91092 19.4829 8.84816 18.5458L11.9999 15.3941L15.1517 18.5458C16.0889 19.4829 17.6083 19.4829 18.5458 18.5458C19.4829 17.6083 19.4829 16.0889 18.5458 15.1517L15.3941 11.9999L18.5458 8.84829C19.4829 7.91092 19.4829 6.39138 18.5458 5.45415Z" fill="currentColor"></path>
      </g> 
    </svg>
  }
}

module Back = {
  @react.component
  let make = () => {
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path 
        d="M19 12H5M5 12L12 19M5 12L12 5" 
        stroke="#999999" 
        strokeWidth="2" 
        strokeLinecap="round" 
        strokeLinejoin="round"
      />
    </svg>
  }
}

module Spinner = {
  @react.component
  let make = (~className="w-5 h-5 text-blue-600") => {
    <svg
      className={`${className} animate-spin`}
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24">
      <circle
        className="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        strokeWidth="4"
      />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      />
    </svg>
  } 
}

module Success = {
  @react.component
  let make = (~className="") => {
    <svg
      className
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      strokeWidth="1.5"
      stroke="currentColor">
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    </svg>
  }
}

module Plus = {
  @react.component
  let make = () => {
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path 
        d="M12 5V19M5 12H19" 
        stroke="currentColor" 
        strokeWidth="2" 
        strokeLinecap="round" 
        strokeLinejoin="round"
      />
    </svg>
  }
}

module Minus = {
  @react.component
  let make = () => {
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path 
        d="M5 12H19" 
        stroke="currentColor" 
        strokeWidth="2" 
        strokeLinecap="round" 
        strokeLinejoin="round"
      />
    </svg>
  }
}

module Synced = {
  @react.component
  let make = (~className="") => {
    <svg
      className
      xmlns="http://www.w3.org/2000/svg"
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round">
      <path d="M12 2v4" />
      <path d="M12 18v4" />
      <path d="m4.93 4.93 2.83 2.83" />
      <path d="m16.24 16.24 2.83 2.83" />
      <path d="M2 12h4" />
      <path d="M18 12h4" />
      <path d="m4.93 19.07 2.83-2.83" />
      <path d="m16.24 7.76 2.83-2.83" />
      <circle cx="12" cy="12" r="4" />
    </svg>
  }
}

module Syncing = {
  @react.component
  let make = (~className="") => {
    <svg
      className={`${className} animate-spin`}
      xmlns="http://www.w3.org/2000/svg"
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round">
      <path d="M21 12a9 9 0 1 1-6.219-8.56" />
    </svg>
  }
}

