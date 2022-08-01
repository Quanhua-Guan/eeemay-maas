import React from "react";
import { Typography } from "antd";

const { Title, Text } = Typography;

// displays a page header

export default function Header({ link, title, subTitle, ...props }) {
  return (
    <div style={{ display: "flex", justifyContent: "space-between", padding: "0.5rem 1.2rem", alignItems: "center" }}>
      <div style={{ display: "flex", flex: 1, flexWrap: "wrap", alignItems: "center" }}>
        <Title level={4} style={{ margin: "0 0.5rem 0 0" }}>
          {title}
        </Title>
        <a href={link} target="_blank" rel="noopener noreferrer">
          {subTitle}
        </a>
      </div>
      {props.children}
    </div>
  );
}

Header.defaultProps = {
  link: "https://github.com/Quanhua-Guan/eeemay-maas.git",
  title: "👛 MultiSig Magician 🧙",
  subTitle: "fork me here 🍴",
};
