export interface ApiResponse<T> {
  code: number
  message: string
  data: T
  timestamp: string
}

export interface LoginRequest {
  username: string
  password: string
}

export interface LoginResponse {
  token: string
  username: string
  displayName: string
  role: string
}

export interface CurrentUser {
  username: string
  displayName: string
  role: string
}

export interface ComplaintItem {
  id: number
  title: string
  content: string
  status: string
  createdAt: string
}

export interface EmergencyItem {
  id: number
  title: string
  content: string
  status: string
  createdAt: string
}

export interface SimpleItem {
  id: string
  name: string
  description: string
}
