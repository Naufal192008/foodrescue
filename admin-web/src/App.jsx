import { useState } from 'react'
import { ArrowRight, Check, ChevronLeft, Leaf, LockKeyhole, Mail, MapPin, Store, UserRound } from 'lucide-react'
import './App.css'

const emptyForm = { name: '', email: '', password: '', confirm: '', storeName: '', location: '' }

function App() {
  const [screen, setScreen] = useState('landing')
  const [role, setRole] = useState(null)
  const [form, setForm] = useState(emptyForm)
  const [registered, setRegistered] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('foodrescue_registered_roles')) || { user: false, store: false }
    } catch {
      return { user: false, store: false }
    }
  })
  const [message, setMessage] = useState('')

  const beginRegistration = (selectedRole) => {
    setRole(selectedRole)
    setForm(emptyForm)
    setMessage('')
    setScreen('register')
  }

  const update = (event) => setForm({ ...form, [event.target.name]: event.target.value })

  const register = (event) => {
    event.preventDefault()
    if (form.password !== form.confirm) return setMessage('Konfirmasi password belum sama.')
    if (form.password.length < 8) return setMessage('Password minimal 8 karakter.')
    const nextRegistered = { ...registered, [role]: true }
    setRegistered(nextRegistered)
    localStorage.setItem('foodrescue_registered_roles', JSON.stringify(nextRegistered))
    setMessage('Registrasi berhasil. Sekarang silakan login.')
    setScreen('login')
  }

  const login = (event) => {
    event.preventDefault()
    if (!registered[role]) return setMessage('Silakan registrasi terlebih dahulu sebelum login.')
    setScreen(role === 'store' ? 'store-home' : 'user-home')
  }

  if (screen === 'landing') return <Landing onChoose={beginRegistration} />
  if (screen === 'register') return <AuthShell title={role === 'store' ? 'Buka toko di FoodRescue' : 'Mulai selamatkan makanan'} subtitle={role === 'store' ? 'Daftarkan toko kamu sebelum masuk ke ruang toko.' : 'Buat akun terlebih dahulu sebelum masuk ke aplikasi.'} onBack={() => setScreen('landing')}><RegisterForm role={role} form={form} update={update} submit={register} message={message} /></AuthShell>
  if (screen === 'login') return <AuthShell title={role === 'store' ? 'Masuk ke ruang toko' : 'Masuk sebagai user'} subtitle="Akun sudah terdaftar? Lanjutkan ke FoodRescue." onBack={() => setScreen('landing')}><LoginForm form={form} update={update} submit={login} message={message} onRegister={() => setScreen('register')} /></AuthShell>
  return <MemberHome role={role} name={form.name || (role === 'store' ? form.storeName : 'FoodRescue member')} onLogout={() => { setScreen('landing'); setRole(null) }} />
}

function Landing({ onChoose }) {
  return <main className="landing"><nav className="landing-nav"><div className="logo"><span>FR</span><strong>FoodRescue</strong></div><span className="nav-note">Rescue more. Waste less.</span></nav><section className="hero"><div className="hero-copy"><div className="pill"><Leaf size={14} /> Gerakan pangan yang lebih baik</div><h1>Makanan baik<br /><i>tidak berakhir</i><br />di tempat sampah.</h1><p>Temukan makanan surplus dari toko sekitar, atau bantu lebih banyak orang dengan membuka toko di FoodRescue.</p><div className="choice-grid"><button className="choice-card user-choice" onClick={() => onChoose('user')}><div className="choice-icon"><UserRound size={23} /></div><span className="choice-label">Untuk saya</span><strong>Login User</strong><small>Jelajahi makanan surplus dan hemat lebih banyak.</small><ArrowRight size={18} /></button><button className="choice-card store-choice" onClick={() => onChoose('store')}><div className="choice-icon"><Store size={23} /></div><span className="choice-label">Untuk bisnis</span><strong>Buka Toko</strong><small>Jual surplus makanan dan tumbuhkan dampakmu.</small><ArrowRight size={18} /></button></div><p className="login-note">Registrasi wajib dilakukan sebelum login pertama.</p></div><div className="hero-art"><div className="art-sun" /><div className="art-card art-main"><span>HARI INI</span><strong>1.248</strong><small>makanan diselamatkan</small><div className="progress"><i /></div></div><div className="art-card art-float"><Leaf size={17} /><strong>− 2,4 ton</strong><small>food waste</small></div><div className="art-ring" /><div className="leaf-shape">✦</div></div></section><footer className="landing-footer"><span>© 2026 FoodRescue</span><span><Check size={14} /> Dibuat untuk bumi yang lebih ringan</span></footer></main>
}

function AuthShell({ title, subtitle, onBack, children }) { return <main className="auth-page"><div className="auth-aside"><button className="back-link" onClick={onBack}><ChevronLeft size={17} />Kembali</button><div className="logo light"><span>FR</span><strong>FoodRescue</strong></div><div className="aside-copy"><Leaf size={27} /><h2>Setiap pilihan kecil membuat perbedaan besar.</h2><p>Bersama kita selamatkan makanan, dukung bisnis lokal, dan kurangi sampah.</p></div></div><section className="auth-panel"><div className="auth-box"><button className="auth-back-button" onClick={onBack}><ChevronLeft size={17} />Kembali</button><div className="auth-heading"><span className="auth-mark">{title.startsWith('Buka') || title.startsWith('Masuk ke') ? <Store size={20} /> : <UserRound size={20} />}</span><h1>{title}</h1><p>{subtitle}</p></div>{children}</div></section></main> }

function RegisterForm({ role, form, update, submit, message }) { return <form className="auth-form" onSubmit={submit}>{role === 'store' ? <label>Nama toko<div className="input-wrap"><Store size={17} /><input name="storeName" value={form.storeName} onChange={update} required placeholder="Contoh: Kopi Senja" /></div></label> : <label>Nama lengkap<div className="input-wrap"><UserRound size={17} /><input name="name" value={form.name} onChange={update} required placeholder="Nama kamu" /></div></label>}<label>Email<div className="input-wrap"><Mail size={17} /><input type="email" name="email" value={form.email} onChange={update} required placeholder="kamu@email.com" /></div></label>{role === 'store' && <label>Lokasi toko<div className="input-wrap"><MapPin size={17} /><input name="location" value={form.location} onChange={update} required placeholder="Jakarta Selatan" /></div></label>}<label>Password<div className="input-wrap"><LockKeyhole size={17} /><input type="password" name="password" value={form.password} onChange={update} required placeholder="Minimal 8 karakter" /></div></label><label>Konfirmasi password<div className="input-wrap"><LockKeyhole size={17} /><input type="password" name="confirm" value={form.confirm} onChange={update} required placeholder="Ulangi password" /></div></label>{message && <div className="form-message">{message}</div>}<button className="submit-button" type="submit">Daftar dan lanjut login <ArrowRight size={17} /></button></form> }

function LoginForm({ form, update, submit, message, onRegister }) { return <form className="auth-form" onSubmit={submit}><label>Email<div className="input-wrap"><Mail size={17} /><input type="email" name="email" value={form.email} onChange={update} required placeholder="kamu@email.com" /></div></label><label>Password<div className="input-wrap"><LockKeyhole size={17} /><input type="password" name="password" value={form.password} onChange={update} required placeholder="Password kamu" /></div></label>{message && <div className="form-message">{message}</div>}<button className="submit-button" type="submit">Masuk <ArrowRight size={17} /></button><p className="switch-note">Belum punya akun? <button type="button" onClick={onRegister}>Registrasi dulu</button></p></form> }

function MemberHome({ role, name, onLogout }) { return <main className="member-page"><nav className="landing-nav"><div className="logo"><span>FR</span><strong>FoodRescue</strong></div><button className="outline-button" onClick={onLogout}>Keluar</button></nav><section className="member-hero"><div className="pill"><Check size={14} /> Login berhasil</div><h1>{role === 'store' ? `Halo, ${name}.` : `Selamat datang, ${name}.`}</h1><p>{role === 'store' ? 'Ruang toko kamu siap digunakan. Tambahkan makanan surplus pertamamu.' : 'Temukan makanan surplus di sekitar dan buat dampak hari ini.'}</p><button className="submit-button">Mulai sekarang <ArrowRight size={17} /></button></section></main> }

export default App
