import React, { useState, useEffect } from 'react';
import { Card, Statistic, Row, Col, Progress, List, Tag } from 'antd';
import { AlertOutlined, CheckCircleOutlined, ClockCircleOutlined, LineChartOutlined } from '@ant-design/icons';
import axios from 'axios';

const API_BASE = process.env.REACT_APP_API_URL || 'http://localhost:4000';

function FraudKPIDashboard() {
  const [cases, setCases] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchCases();
    const interval = setInterval(fetchCases, 10000);
    return () => clearInterval(interval);
  }, []);

  const fetchCases = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_BASE}/api/fabric/cases`);
      setCases(response.data.cases || []);
    } catch (error) {
      console.error('Error fetching cases for KPI dashboard:', error);
    } finally {
      setLoading(false);
    }
  };

  const totalCases = cases.length;
  const activeFreezes = cases.filter(c => c.freeze_active).length;
  const submittedCases = cases.filter(c => c.status === 'SUBMITTED').length;
  const freezeRequested = cases.filter(c => c.status === 'FREEZE_REQUESTED').length;
  const approvedFreezes = cases.filter(
    c => c.status === 'FREEZE_APPROVED' || c.status === 'FREEZE_ACTIVE'
  ).length;

  const totalFreezeFlow = freezeRequested + approvedFreezes + activeFreezes;
  const approvalRate = totalFreezeFlow
    ? Math.round((approvedFreezes / totalFreezeFlow) * 100)
    : 0;

  const latestCases = [...cases]
    .sort((a, b) => {
      const at = new Date(a.created_at || 0).getTime();
      const bt = new Date(b.created_at || 0).getTime();
      return bt - at;
    })
    .slice(0, 5);

  const statusColor = (status) => {
    switch (status) {
      case 'SUBMITTED':
        return 'blue';
      case 'FREEZE_REQUESTED':
        return 'orange';
      case 'FREEZE_APPROVED':
      case 'FREEZE_ACTIVE':
        return 'green';
      default:
        return 'default';
    }
  };

  return (
    <div>
      <h2>Fraud KPIs Overview</h2>
      <p style={{ marginBottom: 24 }}>
        High-level view of investigation workload and freeze actions across the system.
      </p>

      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col xs={24} md={6}>
          <Card loading={loading}>
            <Statistic
              title="Total Cases"
              value={totalCases}
              prefix={<AlertOutlined />}
            />
          </Card>
        </Col>
        <Col xs={24} md={6}>
          <Card loading={loading}>
            <Statistic
              title="Active Freezes"
              value={activeFreezes}
              prefix={<CheckCircleOutlined />}
              valueStyle={{ color: '#3f8600' }}
            />
          </Card>
        </Col>
        <Col xs={24} md={6}>
          <Card loading={loading}>
            <Statistic
              title="Freeze Requests"
              value={freezeRequested}
              prefix={<ClockCircleOutlined />}
              valueStyle={{ color: '#cf1322' }}
            />
          </Card>
        </Col>
        <Col xs={24} md={6}>
          <Card loading={loading}>
            <Statistic
              title="Submitted Cases"
              value={submittedCases}
              prefix={<LineChartOutlined />}
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col xs={24} md={8}>
          <Card title="Freeze Approval Rate" loading={loading} style={{ textAlign: 'center' }}>
            <Progress
              type="dashboard"
              percent={approvalRate}
              format={(p) => `${p || 0}%`}
            />
          </Card>
        </Col>
        <Col xs={24} md={16}>
          <Card title="Latest Cases" loading={loading}>
            <List
              dataSource={latestCases}
              locale={{ emptyText: 'No cases yet. Run the demo or submit a bank report.' }}
              renderItem={(item) => (
                <List.Item>
                  <List.Item.Meta
                    title={item.case_id || 'Unknown Case'}
                    description={`Status: ${item.status || 'N/A'}${
                      item.evidence_hash
                        ? ` | Evidence: ${item.evidence_hash.slice(0, 16)}...`
                        : ''
                    }`}
                  />
                  <Tag color={statusColor(item.status)}>{item.status || 'UNKNOWN'}</Tag>
                </List.Item>
              )}
            />
          </Card>
        </Col>
      </Row>
    </div>
  );
}

export default FraudKPIDashboard;
