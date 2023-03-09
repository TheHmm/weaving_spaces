import * as React from "react";
import ReactDOM from "react-dom/client";

import Form from "@rjsf/antd";
import { FormProps } from "@rjsf/core";
import { RJSFSchema } from "@rjsf/utils";
import validator from "@rjsf/validator-ajv8";

interface Props {
  schema: RJSFSchema;
  uiSchema: FormProps["uiSchema"];
  onChange: (data: any) => void;
  data: any;
}

const LiveForm: React.FC<Props> = (props) => {
  const [formData, setFormData] = React.useState(props.data);

  return (
    <Form
      idPrefix="rjsf"
      schema={props.schema}
      uiSchema={props.uiSchema}
      validator={validator}
      formData={formData}
      onChange={(e) => {
        setFormData(e.formData);
        props.onChange(e.formData);
      }}
    >
      <span />
    </Form>
  );
};

export default {
  mounted() {
    const hidden = this.el.querySelector("input");

    const onChange = (formData: any) => {
      hidden.setAttribute("value", JSON.stringify(formData));
    };

    const schema: RJSFSchema = JSON.parse(this.el.dataset.schema);
    const uiSchema = JSON.parse(this.el.dataset.uiSchema);

    const data = JSON.parse(hidden.value || "{}");

    const rootEl = this.el.querySelector(".root");
    const root = ReactDOM.createRoot(rootEl);
    root.render(
      <LiveForm
        schema={schema}
        uiSchema={uiSchema}
        onChange={onChange}
        data={data}
      />
    );
  },
};
