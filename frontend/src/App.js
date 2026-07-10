import React, { useState } from 'react';
import { Layout, Menu } from 'antd';

// Lazy-load heavy views for better initial load performance
const Dashboard = React.lazy(() => import('./components/Dashboard'));
const BankReport = React.lazy(() => import('./components/BankReport'));
const LEADashboard = React.lazy(() => import('./components/LEADashboard'));
const LEAQueue = React.lazy(() => import('./components/LEAQueue'));
const InvestigatorTrace = React.lazy(() => import('./components/InvestigatorTrace'));
const EvidenceViewer = React.lazy(() => import('./components/EvidenceViewer'));
const FraudKPIDashboard = React.lazy(() => import('./components/FraudKPIDashboard'));

import './App.css';

const { Header, Content, Sider } = Layout;

function App() {
  const [selectedView, setSelectedView] = useState('dashboard');

  const menuItems = [
    { key: 'dashboard', label: 'Dashboard' },
    { key: 'fraud-kpi-dashboard', label: 'Fraud KPIs' },
    { key: 'bank-report', label: 'Bank Report' },
    { key: 'lea-dashboard', label: 'LEA Dashboard' },
    { key: 'lea-queue', label: 'LEA Queue' },
    { key: 'investigator-trace', label: 'Investigator Trace' },
    { key: 'evidence-viewer', label: 'Evidence Viewer' }
  ];

  const renderContent = () => {
    switch (selectedView) {
      case 'dashboard':
        return <Dashboard />;
      case 'fraud-kpi-dashboard':
        return <FraudKPIDashboard />;
      case 'bank-report':
        return <BankReport />;
      case 'lea-dashboard':
        return <LEADashboard />;
      case 'lea-queue':
        return <LEAQueue />;
      case 'investigator-trace':
        return <InvestigatorTrace />;
      case 'evidence-viewer':
        return <EvidenceViewer />;
      default:
        return <Dashboard />;
    }
  };

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Header style={{ background: '#001529', color: '#fff', padding: '0 24px' }}>
        <h1 style={{ color: '#fff', margin: 0, lineHeight: '64px' }}>
          Fraud Trail System - Investigator UI
        </h1>
      </Header>
      <Layout>
        <Sider width={200} style={{ background: '#fff' }}>
          <Menu
            mode="inline"
            selectedKeys={[selectedView]}
            style={{ height: '100%', borderRight: 0 }}
            items={menuItems}
            onClick={({ key }) => setSelectedView(key)}
          />
        </Sider>
        <Content style={{ padding: '24px', background: '#f0f2f5' }}>
          <React.Suspense fallback={<div>Loading view...</div>}>
            {renderContent()}
          </React.Suspense>
        </Content>
      </Layout>
    </Layout>
  );
}

export default App;
