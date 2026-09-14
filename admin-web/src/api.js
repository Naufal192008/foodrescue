const API_BASE_URL = import.meta.env.VITE_API_BASE_URL?.replace(/\/$/, '')

export async function apiRequest(path, options = {}) {
  if (!API_BASE_URL) {
    throw new Error('VITE_API_BASE_URL belum dikonfigurasi')
  }
  if (!API_BASE_URL.startsWith('https://')) {
    throw new Error('API admin wajib menggunakan HTTPS')
  }

  const token = sessionStorage.getItem('foodrescue_admin_token')
  const response = await fetch(`${API_BASE_URL}/${path.replace(/^\//, '')}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(options.headers || {}),
    },
  })

  if (response.status === 401 || response.status === 403) {
    sessionStorage.removeItem('foodrescue_admin_token')
    throw new Error('Sesi admin tidak valid atau akses ditolak')
  }
  if (!response.ok) throw new Error('Permintaan ke server gagal')
  return response.status === 204 ? null : response.json()
}

export const adminApi = {
  login: (email, password) => apiRequest('/admin/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  }),
  products: () => apiRequest('/admin/products'),
  users: () => apiRequest('/admin/users'),
  orders: () => apiRequest('/admin/orders'),
}

export const authApi = {
  registerUser: (payload) => apiRequest('/auth/register/user', {
    method: 'POST',
    body: JSON.stringify(payload),
  }),
  registerStore: (payload) => apiRequest('/auth/register/store', {
    method: 'POST',
    body: JSON.stringify(payload),
  }),
  loginUser: (email, password) => apiRequest('/auth/login/user', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  }),
  loginStore: (email, password) => apiRequest('/auth/login/store', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  }),
}
